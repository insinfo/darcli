import 'dart:async';

import 'package:new_sali_core/new_sali_core.dart';
import 'package:ngdart/angular.dart';

import 'tree_view_base.dart';

import 'dart:html' as html;

@Component(
  selector: 'simple-treeview',
  styleUrls: ['simple_treeview.css'],
  templateUrl: 'simple_treeview.html',
  directives: [
    coreDirectives,
    // NgTemplateOutlet,
  ],
)
class SimpleTreeViewComponent {
  @ViewChild('treeContainer')
  html.DivElement? treeContainer;

  @Input('searchPlaceholder')
  String searchPlaceholder = 'Digite e pressione enter para buscar';

  @Input('data')
  List<TreeViewNode> list = <TreeViewNode>[];

  @Input('isMultiSelectable')
  bool isMultiSelectable = false;

  @Input('isDisableEnter')
  bool isDisableEnter = false;

  TreeViewNode? itemSelected;

  void searchKeydownEnter(inputsearch) {
    search(inputsearch.value);
  }

  void search(String value) {
    search2(value, list);
  }

  void search2(String _search_query, List<TreeViewNode> json_tree,
      [TreeViewNode? parent]) {
    var search_query =
        SaliCoreUtils.removerAcentos(_search_query).toLowerCase();

    for (var i = 0; i < json_tree.length; i++) {
      var menu_item = json_tree[i];

      menu_item.parent = parent;

      if (search_query.isNotEmpty == true) {
        menu_item.treeViewNodeFilter = false;
      } else {
        menu_item.treeViewNodeFilter = true;
      }

      if (menu_item.hasChilds()) {
        search2(search_query, menu_item.treeViewNodes, menu_item);
      } else {
        // volta do extremo para o topo da árvore
        var item_endp = menu_item;

        while (item_endp.parent != null) {
          if (item_endp.treeViewNodeFilter == false) {
            if (item_endp.finded(search_query, item_endp)) {
              item_endp.treeViewNodeFilter = true;
              item_endp.parent?.treeViewNodeFilter = true;
              item_endp.parent?.treeViewNodeIsCollapse = false;
            }
          } else {
            item_endp.parent?.treeViewNodeFilter = true;
            item_endp.parent?.treeViewNodeIsCollapse = false;
          }

          item_endp = item_endp.parent!;
        }

        if (item_endp.parent == null && item_endp.treeViewNodeFilter == false) {
          if (item_endp.finded(search_query, item_endp)) {
            item_endp.treeViewNodeFilter = true;
            item_endp.parent?.treeViewNodeIsCollapse = false;
          }
        }
      }
    }

    if (search_query.isEmpty) {
      closeAllTree(json_tree);
    }
  }

  void closeAllTree(List<TreeViewNode> json_tree) {
    json_tree.forEach((element) {
      element.treeViewNodeIsCollapse = true;
      closeAllTree(element.treeViewNodes);
    });
  }

  void unselectAllTreeModel(List<TreeViewNode> json_tree) {
    json_tree.forEach((node) {
      node.treeViewNodeIsSelected = false;
      unselectAllTreeModel(node.treeViewNodes);
    });
  }

  void selectAllTreeModel(List<TreeViewNode> tree) {
    tree.forEach((node) {
      node.treeViewNodeIsSelected = true;
      if (node.treeViewNodeLevel < 1) {
        node.treeViewNodeIsCollapse = false;
      }
      selectAllTreeModel(node.treeViewNodes);
    });
  }

  ///define all node of tree as treeViewNodeIsCollapse = false
  void expandAllTreeModel(List<TreeViewNode> tree) {
    for (var node in tree) {
      node.treeViewNodeIsCollapse = false;
      if (node.treeViewNodes.isNotEmpty) {
        expandAllTreeModel(node.treeViewNodes);
      }
    }
  }

  ///define all node of tree as treeViewNodeIsCollapse = true
  void collapseAllTreeModel(List<TreeViewNode> tree) {
    for (var node in tree) {
      node.treeViewNodeIsCollapse = true;
      if (node.treeViewNodes.isNotEmpty) {
        expandAllTreeModel(node.treeViewNodes);
      }
    }
  }

  bool isSelectAll = false;
  void selectAllToogleAction() {
    if (isSelectAll) {
      isSelectAll = false;
      unselectAllAction();
    } else {
      isSelectAll = true;
      selectAllAction();
    }
  }

  void selectAllAction() {
    selectAllTreeModel(list);
  }

  void unselectAllAction() {
    unselectAllTreeModel(list);
  }

  bool isExpandAll = false;

  void expandAllToogleAction() {
    if (isExpandAll) {
      isExpandAll = false;
      collapseAllTreeModel(list);
    } else {
      isExpandAll = true;
      expandAllTreeModel(list);
    }
  }

  /// retorna a propriedade value de cada node selecionado da arvore ignorando os value null
  /// [onlyNoChild] se true retorna apenas os selecionados que não tem filhos
  List<T> getAllSelected<T>({bool onlyNoChild = true}) {
    return _getAllSelectedRecursive(list, onlyNoChild: onlyNoChild);
  }

  /// retorna os itens selcionados da arvore recursivamente
  /// [onlyNoChild] se true retorna apenas os selecionados que não tem filhos
  List<T> _getAllSelectedRecursive<T>(List<TreeViewNode> tree,
      {bool onlyNoChild = true}) {
    var result = <T>[];
    tree.forEach((node) {
      if (node.treeViewNodeIsSelected) {
        if (onlyNoChild) {
          if (!node.hasChilds() && node.value != null) {
            result.add(node.value as T);
          }
        } else {
          if (node.value != null) {
            result.add(node.value as T);
          }
        }
      }
      if (node.treeViewNodes.isNotEmpty == true) {
        result.addAll(_getAllSelectedRecursive(node.treeViewNodes));
      }
    });
    return result;
  }

  StreamController<List<dynamic>> onSelectStreamController =
      StreamController<List<dynamic>>();

  @Output('onSelect')
  Stream get onSelect => onSelectStreamController.stream;

  void selectItem(TreeViewNode node) {
    
    node.treeViewNodeIsSelected = !node.treeViewNodeIsSelected;
    if (node.treeViewNodeIsSelected) {
      itemSelected = node;
    }

    // verifica se é um pai de varios filhos ou um filho
    var isPai = node.hasChilds();
    if (isPai) {
      node.getAllDescendants().forEach((el) {
        el.treeViewNodeIsSelected = node.treeViewNodeIsSelected;
      });
    }

    // pega os pais para selecionalos quando o filho é selecionado
    var parents = node.getParents();
    for (var parent in parents) {
      //pega o primeiro filho que esta selecionado
      var childSelected = parent.getChild((n) => n.treeViewNodeIsSelected);
      if (node.treeViewNodeIsSelected) {
        if (childSelected != null) {
          parent.treeViewNodeIsSelected = true;
        }
      } else {
        if (childSelected == null) {
          parent.treeViewNodeIsSelected = false;
        }
      }
    }

    // n.treeViewNodeIsSelected = node.treeViewNodeIsSelected == true ? true : false;
    //onSelectStreamController.add(getAllSelected());
  }
}
