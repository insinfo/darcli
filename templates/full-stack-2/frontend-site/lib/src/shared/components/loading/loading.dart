import 'dart:html';

class SimpleLoading {
  Element _root = DivElement();

  void showHorizontal({Element? target}) {
    _root = DivElement();
    _root.style.width = '100%';
    // _root.style.height = '100%';
    _root.style.position = 'absolute';
    _root.style.left = '0';
    _root.style.top = '0';
    _root.style.zIndex = '1000';

    var backColor = '#2196f3';
    var frontColor = '#fff';

    // ignore: unsafe_html
    _root.setInnerHtml('''
<style>
.loader { 
  width:100%; 
  margin:0 auto; 
  position:relative;
  padding:0;
  height: 3px;
  background-color: $backColor; 
}
.loader:before {
  content:'';
  position:absolute;
  top:0; 
  right:0; 
  bottom:0; 
  left:0;
}
.loader .loaderBar { 
  position:absolute;
  height: 3px;
  border-radius:0;
  top:0;
  right:100%;
  bottom:0;
  left:0;
  background: $frontColor; 
  width:0;
  animation:borealisBar 2s linear infinite;
}
@keyframes borealisBar {
  0% {
    left:0%;
    right:100%;
    width:0%;
  }
  10% {
    left:0%;
    right:75%;
    width:25%;
  }
  90% {
    right:0%;
    left:75%;
    width:25%;
  }
  100% {
    left:100%;
    right:0%;
    width:0%;
  }
}
</style>
<div class="loader">
  <div class="loaderBar"></div>
</div>
''', treeSanitizer: NodeTreeSanitizer.trusted);

    if (target != null) {
      target.append(_root);
    } else {
      document.querySelector('body')?.append(_root);
    }
  }

  void showHorizontal2({Element? target}) {
    _root = DivElement();
    _root.style.width = '100%';
    // _root.style.height = '100%';
    _root.style.position = 'absolute';
    _root.style.left = '0';
    _root.style.top = '0';
    _root.style.zIndex = '1000';

    // ignore: unsafe_html
    _root.setInnerHtml(''' <style>
        .progress-container.indeterminate {
          background-color: #c6dafc
        }
        .progress-container {
          position: relative;
          height: 100%;
          background-color: #e0e0e0;
          overflow: hidden
        }
        .progress-container.indeterminate.fallback>.secondary-progress {
          animation-name: indeterminate-secondary-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        .progress-container.indeterminate>.secondary-progress {
          background-color: #4285f4
        }
        .secondary-progress {
          background-color: #a1c2fa
        }
        .active-progress,
        .secondary-progress {
          transform-origin: left center;
          transform: scaleX(0);
          position: absolute;
          top: 0;
          transition: transform 218ms cubic-bezier(.4, 0, .2, 1);
          right: 0;
          bottom: 0;
          left: 0;
          will-change: transform
        }
        .progress-container {
          position: relative;
          height: 100%;
          background-color: #e0e0e0;
          overflow: hidden
        }
        .progress-container.indeterminate {
          background-color: #c6dafc
        }
        .progress-container.indeterminate>.secondary-progress {
          background-color: #4285f4
        }
        .active-progress,
        .secondary-progress {
          transform-origin: left center;
          transform: scaleX(0);
          position: absolute;
          top: 0;
          transition: transform 218ms cubic-bezier(.4, 0, .2, 1);
          right: 0;
          bottom: 0;
          left: 0;
          will-change: transform
        }
        .active-progress {
          background-color: #4285f4
        }
        .secondary-progress {
          background-color: #a1c2fa
        }
        .progress-container.indeterminate.fallback>.active-progress {
          animation-name: indeterminate-active-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        .progress-container.indeterminate.fallback>.secondary-progress {
          animation-name: indeterminate-secondary-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        @keyframes indeterminate-active-progress {
          0% {
            transform: translate(0) scaleX(0)
          }
          25% {
            transform: translate(0) scaleX(.5)
          }
          50% {
            transform: translate(25%) scaleX(.75)
          }
          75% {
            transform: translate(100%) scaleX(0)
          }
          100% {
            transform: translate(100%) scaleX(0)
          }
        }
        @keyframes indeterminate-secondary-progress {
          0% {
            transform: translate(0) scaleX(0)
          }
          60% {
            transform: translate(0) scaleX(0)
          }
          80% {
            transform: translate(0) scaleX(.6)
          }
          100% {
            transform: translate(100%) scaleX(.1)
          }
        }
        .loadContainer {
            width: 100%;
          /*display: inline-block;        
          height: calc(100vh - 40vh);
          padding-top: 40vh;
          text-align: center;
          vertical-align: middle*/
        }
        .loadingC {
           width: 100%;
           height: 4px
          /*display: inline-block;
          vertical-align: middle;*/       
        }
      </style>
      <div class="loadContainer">
        <div class="loadingC">
          <!--<span>Carregando...</span>-->
          <div class="progress-container _ngcontent-xao-51 indeterminate fallback" role="progressbar"
            aria-label="loading" aria-valuemin="0" aria-valuemax="100">
            <div class="secondary-progress _ngcontent-xao-51" aria-label="active progress 0 secondary progress 0"
              style="transform: scaleX(0);"></div>
            <div class="active-progress _ngcontent-xao-51" style="transform: scaleX(0);"></div>
          </div>
        </div>
      </div>''', treeSanitizer: NodeTreeSanitizer.trusted);

    if (target != null) {
      target.append(_root);
    } else {
      document.querySelector('body')?.append(_root);
    }
  }

  void show({Element? target}) {
    _root = DivElement();
    _root.style.width = '100%';
    _root.style.height = '100%';
    _root.style.background = 'rgb(255 255 255 / 48%)';
    _root.style.position = 'absolute';
    _root.style.left = '0';
    _root.style.top = '0';
    _root.style.zIndex = '1000';
    _root.style.display = 'flex';
    _root.style.flexDirection = 'column';
    _root.style.alignItems = 'center';
    _root.style.justifyContent = 'center';

    _root.appendHtml('''
<div>
<i class="icon-spinner2 spinner icon-2x text-primary"></i>
</div>
''');

    if (target != null) {
      target.append(_root);
    } else {
      document.querySelector('body')?.append(_root);
    }
  }

  void hide() {
    _root.remove();
  }
}
