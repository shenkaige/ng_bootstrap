import 'package:angular2/angular2.dart';
import 'package:ng_bootstrap/core/position.dart';
import 'dart:async';
import 'dart:html';

/// Options passed when creating a new Tooltip
class TooltipOptions {
  /// Construct the options for tooltip
  const TooltipOptions(
      {this.placement,
      this.popupClass,
      this.animation,
      this.isOpen,
      this.content,
      this.hostEl});

  /// tooltip positioning instruction, supported positions: 'top', 'bottom', 'left', 'right'
  final String placement;

  /// (*not implemented*) - custom tooltip class applied to the tooltip container.
  final String popupClass;

  final bool animation;

  /// if `true` tooltip is currently visible
  final bool isOpen;

  /// text of tooltip
  final content;

  final ElementRef hostEl;
}

@Component(
    selector: 'bs-tooltip-container',
    templateUrl: 'container.html',
    encapsulation: ViewEncapsulation.None)
class TooltipContainer implements AfterViewInit {
  /// Constructs a new [TooltipContainer] injecting its [elementRef] and the [options]
  TooltipContainer(this.elementRef, this.cdr, TooltipOptions options) {
    classMap = {'in': false, 'fade': false};
    placement = options.placement;
    popupClass = options.popupClass;
    animation = options.animation;
    isOpen = options.isOpen;
    content = options.content;
    hostEl = options.hostEl;
    classMap[placement] = true;
  }

  ChangeDetectorRef cdr;

  /// Current element DOM reference
  ElementRef elementRef;

  /// map of css classes values
  Map<String, dynamic> classMap;

  /// value in pixels of the top style
  String top;

  /// value in pixels of the left style
  String left;

  /// display style of the tooltip
  String display;

  /// text of tooltip
  String content;

  String placement = 'top';

  /// (*not implemented*) (`?boolean=false`) - if `true` tooltip will be appended to body
  bool appendToBody = false;

  /// if `true` tooltip is currently visible
  bool isOpen;

  /// (*not implemented*) (`?string`) - custom tooltip class applied to the tooltip container.
  String popupClass;

  /// if `false` fade tooltip animation will be disabled
  bool animation;

  ElementRef hostEl;

  /// positions its DOM element next to the parent in the desired position
  @override
  ngAfterViewInit() {
    display = 'block';
    var p = positionElements(hostEl.nativeElement,
        elementRef.nativeElement.children[0], placement, appendToBody);
    top = p.top.toString() + 'px';
    left = p.left.toString() + 'px';
    classMap['in'] = true;
  }
}

@Directive(selector: '[bsTooltip]')
class Tooltip {
  /// Constructs a new [Tooltip] injecting [viewContainerRef] and [loader]
  Tooltip(this.viewContainerRef, this.loader);

  /// Reference to HTML DOM
  ViewContainerRef viewContainerRef;

  /// load components dynamically
  DynamicComponentLoader loader;

  ///
  bool visible = false;

  /// text of tooltip
  @Input('bsTooltip')
  String content;

  /// tooltip positioning instruction, supported positions: 'top', 'bottom', 'left', 'right'
  @Input('bsTooltipPlacement')
  String placement = 'top';

  /// (*not implemented*) (`?boolean=false`) - if `true` tooltip will be appended to body
  @Input('bsTooltipAppendToBody')
  bool appendToBody = false;

  /// if `true` tooltip is currently visible
  @Input('bsTooltipIsOpen')
  bool isOpen;

  bool _enable = true;

  /// if `false` tooltip is disabled and will not be shown
  @Input('bsTooltipEnable')
  set enable(bool enable) {
    _enable = enable ?? true;
    if (!_enable) {
      hide();
    }
  }

  /// array of event names which triggers tooltip opening
  @Input('bsTooltipTrigger')
  String trigger;

  /// (*not implemented*) (`?string`) - custom tooltip class applied to the tooltip container.
  @Input('bsTooltipClass')
  String popupClass;

  /// DOM reference to tooltip component
  Future<ComponentRef> tooltip;

  /// show the tooltip when mouseleave and focusout events happens
  @HostListener('mouseenter', const ['\$event'])
  @HostListener('focusin', const ['\$event'])
  show([Event event]) {
    if (event is MouseEvent && trigger == 'focus' ||
        event is FocusEvent && trigger == 'mouse') {
      return;
    }
    if (visible || !_enable) {
      return;
    }
    visible = true;
    var options = new TooltipOptions(
        content: content,
        placement: placement,
        popupClass: popupClass,
        hostEl: viewContainerRef.element);
    var providers = ReflectiveInjector
        .resolve([provide(TooltipOptions, useValue: options)]);
    tooltip = loader.loadNextToLocation(
        TooltipContainer, viewContainerRef, providers);
  }

  /// hide the tooltip when mouseleave and focusout events happens
  @HostListener('mouseleave', const ['\$event'])
  @HostListener('focusout', const ['\$event'])
  hide([Event event]) {
    if (event is MouseEvent && trigger == 'focus' ||
        event is FocusEvent && trigger == 'mouse') {
      return;
    }
    if (!visible) {
      return;
    }
    visible = false;
    tooltip.then((ComponentRef componentRef) {
      componentRef.destroy();
      return componentRef;
    });
  }
}

