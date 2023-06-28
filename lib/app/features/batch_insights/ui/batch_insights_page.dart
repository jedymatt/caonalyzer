import 'package:caonalyzer/app/features/batch_insights/bloc/batch_insights_bloc.dart';
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

          if (state is! BatchInsightsSuccess) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Average mold per image: ${(state.averageMoldPerImage * 100).toStringAsFixed(2)}%'),
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
