import 'package:flutter/material.dart';
import 'package:settings_tiles/src/tiles/setting_tile.dart';

class SettingExpandableListTile extends StatefulWidget {
  const SettingExpandableListTile({
    super.key,
    this.visible = true,
    this.enabled = true,
    this.fullempty = false,
    this.icon,
    this.title,
    this.value,
    this.description,
    this.trailing,
    this.onTap,
    this.subItems = const <Widget>[],
    this.chips,
    this.initiallyExpanded = false,
  });

  final bool visible;
  final bool enabled;
  final bool fullempty;
  final Widget? icon;
  final Widget? title;
  final Widget? value;
  final Widget? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final List<Widget> subItems;
  final List<String>? chips;
  final bool initiallyExpanded;

  @override
  State<SettingExpandableListTile> createState() =>
      _SettingExpandableListTileState();
}

class _SettingExpandableListTileState extends State<SettingExpandableListTile>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final hasSubContent =
        widget.subItems.isNotEmpty || (widget.chips?.isNotEmpty ?? false);
    final trailingWidgets = <Widget>[];
    if (widget.trailing != null) trailingWidgets.add(widget.trailing!);
    if (hasSubContent) {
      // trailingWidgets
      //     .add(Icon(_expanded ? Icons.expand_less : Icons.expand_more));
    }

    final subtitleNeeded = widget.value != null || widget.description != null;
    final subtitle = subtitleNeeded
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.value != null) widget.value!,
              if (widget.description != null) _styledText(widget.description!),
            ],
          )
        : null;

    final tile = ListTile(
      contentPadding: widget.fullempty
          ? const EdgeInsets.all(0)
          : const EdgeInsets.only(right: 16, left: 16),
      enabled: widget.enabled,
      leading: widget.icon,
      title: widget.title != null ? _styledText(widget.title!) : null,
      subtitle: subtitle,
      trailing: trailingWidgets.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: trailingWidgets,
            )
          : null,
      onTap: widget.onTap,
    );

    final chipWidgets = (widget.chips ?? <String>[])
        .map((label) => Chip(label: Text(label)))
        .toList();

    final expandedChild = hasSubContent
        ? Column(
            children: [
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(
                  _expanded ? 'Hide subtasks' : 'Show subtasks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing:
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onTap: () => setState(() => _expanded = !_expanded),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.subItems.isNotEmpty) ...widget.subItems,
                            if (chipWidgets.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 14,
                                children: chipWidgets,
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile,
        expandedChild,
      ],
    );
  }

  Widget _styledText(Widget widget) {
    if (widget is Text) {
      return Text(
        widget.data ?? '',
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      );
    }
    return widget;
  }
}
