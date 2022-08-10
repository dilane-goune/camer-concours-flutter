import 'package:carmer_concours/components/concour_item.dart';
import 'package:carmer_concours/components/result_item.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget listView(List<Map<String, dynamic>> data, String type,
    {ScrollController? controller,
    void Function()? getMore,
    bool? isGettingMore = false}) {
  return Parent(
    style: ParentStyle(),
    child: ListView.builder(
      itemBuilder: (context, index) {
        if (data.isEmpty) {
          return const Center(
            child: Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          );
        }
        if (index == data.length) {
          return Center(
            child: TextButton(
              onPressed: getMore != null && !isGettingMore! ? getMore : null,
              child: Text(AppLocalizations.of(context)!.more),
            ),
          );
        }
        if (type == 'Results') {
          return ResultItem.fromObject(data[index]);
        }
        return ConcourItem.fromObject(data[index]);
      },
      // separatorBuilder: (context, index) {
      //   if (index == data.length - 1) {
      //     return const Center(
      //       child: Center(
      //         child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      //       ),
      //     );
      //   }
      //   return Container();
      // },
      itemCount: data.isEmpty ? data.length : data.length + 1,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      controller: controller,
    ),
  );
}
