import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReorderableResponsiveGrid<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(BuildContext context, BoxConstraints constraints,
      List<Widget> children) layoutBuilder;

  const ReorderableResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    required this.layoutBuilder,
  });

  @override
  State<ReorderableResponsiveGrid<T>> createState() =>
      _ReorderableResponsiveGridState<T>();
}

class _ReorderableResponsiveGridState<T>
    extends State<ReorderableResponsiveGrid<T>> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final children = List<Widget>.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final child = widget.itemBuilder(context, index, item);

          return DragTarget<int>(
            onWillAccept: (fromIndex) =>
                fromIndex != null && fromIndex != index,
            onAccept: (fromIndex) {
              widget.onReorder(fromIndex, index);
            },
            builder: (context, candidateData, rejectedData) {
              final isDesktop =
                  kIsWeb || (!Platform.isAndroid && !Platform.isIOS);
              final feedbackWidget = Material(
                elevation: 8,
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.8,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: child,
                  ),
                ),
              );
              final childWhenDraggingWidget = Opacity(
                opacity: 0.3,
                child: child,
              );

              if (isDesktop) {
                return Draggable<int>(
                  data: index,
                  feedback: feedbackWidget,
                  childWhenDragging: childWhenDraggingWidget,
                  child: child,
                );
              }

              return LongPressDraggable<int>(
                data: index,
                feedback: feedbackWidget,
                childWhenDragging: childWhenDraggingWidget,
                child: child,
              );
            },
          );
        });

        return widget.layoutBuilder(context, constraints, children);
      },
    );
  }
}
