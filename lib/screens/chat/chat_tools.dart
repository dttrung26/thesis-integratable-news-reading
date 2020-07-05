import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage getCachedAvatar(String avatarUrl) {
  return CachedNetworkImage(
    placeholder: (context, url) => CircularProgressIndicator(),
    imageUrl: avatarUrl,
    imageBuilder: (context, imageProvider) => CircleAvatar(
      backgroundImage: imageProvider,
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

CachedNetworkImage getCachedImage(String imageUrl) {
  return CachedNetworkImage(
    placeholder: (context, url) => CircularProgressIndicator(),
    imageUrl: imageUrl,
    imageBuilder: (context, imageProvider) => Image.network(
      imageUrl,
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

//var file = await DefaultCacheManager().getFileFromCache(url)
