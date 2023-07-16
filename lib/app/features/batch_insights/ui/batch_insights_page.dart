import 'package:caonalyzer/app/features/batch_insights/bloc/batch_insights_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchInsightsPage extends StatefulWidget {
  const BatchInsightsPage({super.key, required this.images});

  final List<String> images;

  @override
  State<BatchInsightsPage> createState() => _BatchInsightsPageState();
}

class _BatchInsightsPageState extends State<BatchInsightsPage> {
  late final BatchInsightsBloc batchInsightsBloc;

  @override
  void initState() {
    super.initState();
    batchInsightsBloc = BatchInsightsBloc()
      ..add(BatchInsightsStarted(images: widget.images));
  }

  @override
  void dispose() {
    super.dispose();
    batchInsightsBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Insights'),
      ),
      body: BlocBuilder<BatchInsightsBloc, BatchInsightsState>(
        bloc: batchInsightsBloc,
        builder: (context, state) {
          if (state is BatchInsightsInitial) {
            return const SizedBox.shrink();
          }

          if (state is BatchInsightsInProgress) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BatchInsightsFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is! BatchInsightsSuccess) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // show how many molds were detected in each image using fl_chart line chart
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: state.moldsCountPerImage
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            preventCurveOverShooting: true,
                            belowBarData: BarAreaData(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Colors.purple,
                                  // Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              show: true,
                            ),
                            color: Colors.deepPurple,
                          ),
                        ],
                        gridData: const FlGridData(
                          horizontalInterval: 1,
                          verticalInterval: 1,
                        ),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text('Moldy Cacao Beans'),
                            sideTitles: SideTitles(
                              interval: 1,
                              showTitles: true,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text('Images'),
                            sideTitles: SideTitles(
                              interval: 1,
                              showTitles: true,
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                    'Average mold per image: ${state.averageMoldPerImage.toStringAsFixed(2)}'),
                Text(
                    'Average overall confidence: ${(state.averageOverallConfidence * 100).toStringAsFixed(2)}%'),
                Text('Molds count: ${state.moldsCount}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
