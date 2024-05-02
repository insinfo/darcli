import 'package:collection/collection.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html;

class TruncateHtmlResult {
  final String html;
  final bool more;
  TruncateHtmlResult(this.html, this.more);
}

class TruncateHtml {
  bool reachedLimit = false;
  int totalLen = 0;
  List<html.Node> toRemove = [];

  static String truncate(String htmlString, {int limit = 25}) {
    final dom = html.parseFragment(htmlString);
    var instance = TruncateHtml();
    var toRemove = instance._walk(dom, limit);
    // remove any nodes that exceed limit
    for (var child in toRemove) {
      child.parentNode?.remove();
    }

    return dom.outerHtml;
  }

  List<html.Node> _walk(html.Node node, int maxLen) {
    if (reachedLimit) {
      if (node.firstChild != null) {
        toRemove.add(node.firstChild!);
      }
    } else {
      // only text nodes should have text,
      // so do the splitting here
      if (node.firstChild?.nodeType == html.Node.TEXT_NODE) {
        var nodeText = node.firstChild!;
        if (nodeText.text != null) {
          var nodeLen = nodeText.text!.length;
          this.totalLen += nodeLen;

          if (this.totalLen > maxLen) {
            nodeText.text = nodeText.text!
                    .substring(0, nodeLen - (this.totalLen - maxLen)) +
                '...';
            this.reachedLimit = true;
          }
        }
      }

      // if node has children, walk its child elements
      if (node.children.isNotEmpty) {
        for (var child in node.children) {
          _walk(child, maxLen);
        }
      }
    }

    return this.toRemove;
  }

  static TruncateHtmlResult truncate2(
    String htmlString, {
    int limit = 25,
    bool preserveTags = true,
    bool wordBreak = false,
    bool preserveWhiteSpace = false,
    String suffix = '...',
    String moreLink = '',
    String moreText = '»',
  }) {
    // var arr = html.replace(/</g, "\n<")
    //     .replace(/>/g, ">\n")
    //     .replace(/\n\n/g, "\n")
    //     .replace(/^\n/g, "")
    //     .replace(/\n$/g, "")
    //     .split("\n");

    final arr = htmlString
        .replaceAll(RegExp('<', multiLine: true), '\n<')
        .replaceAll(RegExp('>', multiLine: true), '>\n')
        .replaceAll(RegExp(r'\n\n', multiLine: true), '\n')
        .replaceAll(RegExp(r'^\n', multiLine: true), '')
        .replaceAll(RegExp(r'\n$', multiLine: true), '')
        .split('\n');

    var sum = 0;
    final tagStack = <String>[];
    var more = false;

    for (var i = 0; i < arr.length; i++) {
      var row = arr[i];
      // count multiple spaces as one character
      if (!preserveWhiteSpace) {
        row = row.replaceAll('[ ]+', ' ');
      }
      if (row.isEmpty) {
        continue;
      }
      var charArr = getCharArr(row);

      if (row[0] != '<') {
        if (sum >= limit) {
          row = '';
        } else if ((sum + charArr.length) >= limit) {
          var cut = limit - sum;

          if (charArr[cut - 1] == ' ') {
            while (cut > 0) {
              cut -= 1;
              if (charArr[cut - 1] != ' ') {
                break;
              }
            }
          } else {
            // slice or sublist
            int add = charArr.slice(cut).indexOf(' ');

            // break on halh of word
            if (!wordBreak) {
              if (add != -1) {
                cut += add;
              } else {
                cut = row.length;
              }
            }
          }

          row = charArr.slice(0, cut).join('') + suffix;

          if (moreLink.isNotEmpty) {
            row += '<a href="' +
                moreLink +
                '" style="display:inline">' +
                moreText +
                '</a>';
          }

          sum = limit;
          more = true;
        } else {
          sum += charArr.length;
        }
      } else if (!preserveTags) {
        row = '';
      } else if (sum >= limit) {
        final tagMatch = RegExp(r'[a-zA-Z]+').firstMatch(row);
        //final tagMatch = row.match(/[a-zA-Z]+/);
        final tagName = tagMatch?.group(0) ?? '';

        if (tagName.isNotEmpty) {
          if (row.substring(0, 2) != '</') {
            tagStack.add(tagName);
            row = '';
          } else {
            while (tagStack.isNotEmpty && tagStack.last != tagName) {
              tagStack.removeLast();
            }

            if (tagStack.isNotEmpty) {
              row = '';
            }
            if (tagStack.isNotEmpty) {
              tagStack.removeLast();
            }
          }
        } else {
          row = '';
        }
      }

      arr[i] = row;
    }

    return TruncateHtmlResult(
        arr.join('\n').replaceAll(RegExp(r'\n'), ''), more);
  }

  /// count symbols (html entities) like one char
  static List<String> getCharArr(String rowCut) {
    final charArr = <String>[];
    final regex = RegExp(r'^&[a-z0-9#]+;');

    for (var i = 0; i < rowCut.length; i++) {
      final subRow = rowCut.substring(i);
      final match = regex.firstMatch(subRow);

      if (match != null) {
        final char = match[0]!;
        charArr.add(char);
        i += (char.length - 1);
      } else {
        charArr.add(rowCut[i]);
      }
    }

    return charArr;
  }

  static List<String> getCharArr2(String rowCut) {
    final charArr = <String>[];
    final regex = RegExp(r'^&[a-z0-9#]+;');

    for (var i = 0; i < rowCut.length; i++) {
      final subRow = rowCut.substring(i);
      final match = regex.firstMatch(subRow);

      if (match != null) {
        final char = match.group(0)!;
        charArr.add(char);
        i += match.group(0)!.length;
      } else {
        charArr.add(rowCut[i]);
      }
    }

    return charArr;
  }
}
