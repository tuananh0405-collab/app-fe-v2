import 'package:flutter/material.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../domain/entities/leave_balance_entity.dart';
import '../../domain/entities/leave_type_entity.dart';

class CompactLeaveBalanceCard extends StatefulWidget {
  final FlutterFlowTheme theme;
  final List<LeaveBalanceEntity> leaveBalances;
  final List<LeaveTypeEntity> leaveTypes;
  final String title;

  const CompactLeaveBalanceCard({
    super.key,
    required this.theme,
    required this.leaveBalances,
    required this.leaveTypes,
    required this.title,
  });

  @override
  State<CompactLeaveBalanceCard> createState() => _CompactLeaveBalanceCardState();
}

class _CompactLeaveBalanceCardState extends State<CompactLeaveBalanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header with dropdown
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: widget.theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: widget.theme.subtitle2.override(
                        color: widget.theme.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: widget.theme.secondaryText,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          /// Compact Balance Chips (collapsible)
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.leaveBalances.map<Widget>((balance) {
              // Find leave type
              LeaveTypeEntity? leaveType;
              try {
                leaveType = widget.leaveTypes.firstWhere(
                  (type) => type.id == balance.leaveTypeId,
                );
              } catch (e) {
                leaveType = null;
              }
              final leaveTypeName = leaveType?.leaveTypeName ?? 'Unknown';
              final colorHex = leaveType?.colorHex ?? '#3B82F6';
              final color = _parseColor(colorHex);

              return InkWell(
                onTap: () => _showBalanceDetailDialog(
                  context,
                  widget.theme,
                  balance,
                  leaveTypeName,
                  color,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.theme.secondaryText.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        leaveTypeName,
                        style: widget.theme.bodyText2.override(
                          color: widget.theme.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.theme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${balance.remainingDays}',
                          style: widget.theme.bodyText2.override(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: widget.theme.secondaryText,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return const Color(0xFF3B82F6); // Default blue
    } catch (e) {
      return const Color(0xFF3B82F6); // Default blue
    }
  }

  void _showBalanceDetailDialog(
    BuildContext context,
    FlutterFlowTheme theme,
    LeaveBalanceEntity balance,
    String leaveTypeName,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      leaveTypeName,
                      style: theme.subtitle1.override(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: theme.secondaryText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Balance Details in 2 columns
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleDetailItem(
                      theme,
                      'Year',
                      '${balance.year}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSimpleDetailItem(
                      theme,
                      'Total',
                      '${balance.totalDays} days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleDetailItem(
                      theme,
                      'Used',
                      '${balance.usedDays} days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSimpleDetailItem(
                      theme,
                      'Pending',
                      '${balance.pendingDays} days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleDetailItem(
                      theme,
                      'Remaining',
                      '${balance.remainingDays} days',
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDetailItem(
    FlutterFlowTheme theme,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.bodyText2.override(
              fontSize: 11,
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.bodyText1.override(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
