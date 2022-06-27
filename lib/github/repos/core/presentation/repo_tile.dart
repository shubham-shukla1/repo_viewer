import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/domain/github_repo.dart';

class RepoTile extends StatelessWidget {
  //operating presentation with entities(which are clean layer)
  final GithubRepo repo;

  const RepoTile({
    Key? key,
    required this.repo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(repo.fullName),
      subtitle: Text(
        repo.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Hero(
        tag: repo.fullName,
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            repo.owner.avatarUrlSmall,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_border),
          Text(
            repo.stargazersCount.toString(),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      onTap: () {
        // AutoRouter.of(context).push(
        //   RepoDetailRoute(repo: repo),
        // );
      },
    );
  }
}
