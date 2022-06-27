import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingRepoTile extends StatelessWidget {
  const LoadingRepoTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //shimmer- recolor anything inside of it
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade300,
      child: ListTile(
        //Constraints go down. Sizes go up. Parent sets position.
        //The screen is the parent of the Container, and it forces the Container to be exactly
        // the same size as the screen.
//So the Container fills the screen and paints it red.
//egContainer(width: 100, height: 100, color: red)
//The red Container wants to be 100 × 100, but it can’t, because the screen forces it to be exactly 
//the same size as the screen. So the Container fills the screen.
//thats why aLIGN



        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            //THE WIDTH WAS FORCED TO TAKE THE WHOLE SPACE, so needed to wrap inside align
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 14,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        leading: const CircleAvatar(),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border),
            Text(
              '',
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
