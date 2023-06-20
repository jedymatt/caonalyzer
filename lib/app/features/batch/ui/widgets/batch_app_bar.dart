import 'package:caonalyzer/app/features/batch/bloc/batch_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BatchAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        final batchBloc = context.read<BatchBloc>();
        if (state is BatchSelectionModeState) {
          return AppBar(
            title: Text('${state.selectedImages.length} selected'),
            leading: IconButton(
              onPressed: () {
                batchBloc.add(BatchCancelSelectionModeEvent(
                  images: state.images,
                ));
              },
              icon: const Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  batchBloc.add(BatchSelectMultipleImagesEvent(
                    images: state.images,
                    selectedImages: [...state.images],
                  ));
                },
                icon: const Icon(Icons.select_all),
              ),
              IconButton(
                // deselect
                onPressed: () {
                  batchBloc.add(BatchSelectMultipleImagesEvent(
                    images: state.images,
                    selectedImages: const [],
                  ));
                },
                icon: const Icon(Icons.deselect),
              ),
            ],
          );
        }

        if (state is BatchSuccessfulFetchImages) {
          return AppBar(title: Text(title), actions: [
            IconButton(
              onPressed: () {
                batchBloc.add(BatchSelectMultipleImagesEvent(
                  images: state.images,
                  selectedImages: const [],
                ));
              },
              icon: const Icon(Icons.checklist),
            )
          ]);
        }

        return AppBar(title: Text(title));
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
