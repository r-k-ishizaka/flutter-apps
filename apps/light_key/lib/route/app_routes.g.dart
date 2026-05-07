// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $homeRoute,
  $legacyTimelineRoute,
  $homeShellRouteData,
  $legacyNotificationsRoute,
  $authRoute,
  $postRoute,
  $settingsRoute,
  $userProfileRoute,
  $noteDetailRoute,
  $imageViewerRoute,
];

RouteBase get $splashRoute =>
    GoRouteData.$route(path: '/', factory: $SplashRoute._fromState);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/home', factory: $HomeRoute._fromState);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $legacyTimelineRoute => GoRouteData.$route(
  path: '/timeline',
  factory: $LegacyTimelineRoute._fromState,
);

mixin $LegacyTimelineRoute on GoRouteData {
  static LegacyTimelineRoute _fromState(GoRouterState state) =>
      const LegacyTimelineRoute();

  @override
  String get location => GoRouteData.$location('/timeline');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeShellRouteData => ShellRouteData.$route(
  factory: $HomeShellRouteDataExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/home/timeline',
      factory: $TimelineRoute._fromState,
    ),
    GoRouteData.$route(
      path: '/home/notifications',
      factory: $NotificationsRoute._fromState,
    ),
  ],
);

extension $HomeShellRouteDataExtension on HomeShellRouteData {
  static HomeShellRouteData _fromState(GoRouterState state) =>
      const HomeShellRouteData();
}

mixin $TimelineRoute on GoRouteData {
  static TimelineRoute _fromState(GoRouterState state) => const TimelineRoute();

  @override
  String get location => GoRouteData.$location('/home/timeline');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NotificationsRoute on GoRouteData {
  static NotificationsRoute _fromState(GoRouterState state) =>
      const NotificationsRoute();

  @override
  String get location => GoRouteData.$location('/home/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $legacyNotificationsRoute => GoRouteData.$route(
  path: '/notifications',
  factory: $LegacyNotificationsRoute._fromState,
);

mixin $LegacyNotificationsRoute on GoRouteData {
  static LegacyNotificationsRoute _fromState(GoRouterState state) =>
      const LegacyNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $authRoute =>
    GoRouteData.$route(path: '/auth', factory: $AuthRoute._fromState);

mixin $AuthRoute on GoRouteData {
  static AuthRoute _fromState(GoRouterState state) => const AuthRoute();

  @override
  String get location => GoRouteData.$location('/auth');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $postRoute =>
    GoRouteData.$route(path: '/post', factory: $PostRoute._fromState);

mixin $PostRoute on GoRouteData {
  static PostRoute _fromState(GoRouterState state) => PostRoute(
    replyToId: state.uri.queryParameters['reply-to-id'],
    replyToUserName: state.uri.queryParameters['reply-to-user-name'],
    replyToText: state.uri.queryParameters['reply-to-text'],
    replyToAvatarUrl: state.uri.queryParameters['reply-to-avatar-url'],
  );

  PostRoute get _self => this as PostRoute;

  @override
  String get location => GoRouteData.$location(
    '/post',
    queryParams: {
      if (_self.replyToId != null) 'reply-to-id': _self.replyToId,
      if (_self.replyToUserName != null)
        'reply-to-user-name': _self.replyToUserName,
      if (_self.replyToText != null) 'reply-to-text': _self.replyToText,
      if (_self.replyToAvatarUrl != null)
        'reply-to-avatar-url': _self.replyToAvatarUrl,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute =>
    GoRouteData.$route(path: '/settings', factory: $SettingsRoute._fromState);

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $userProfileRoute => GoRouteData.$route(
  path: '/users/:userId',
  factory: $UserProfileRoute._fromState,
);

mixin $UserProfileRoute on GoRouteData {
  static UserProfileRoute _fromState(GoRouterState state) =>
      UserProfileRoute(userId: state.pathParameters['userId']!);

  UserProfileRoute get _self => this as UserProfileRoute;

  @override
  String get location =>
      GoRouteData.$location('/users/${Uri.encodeComponent(_self.userId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $noteDetailRoute => GoRouteData.$route(
  path: '/notes/:noteId',
  factory: $NoteDetailRoute._fromState,
);

mixin $NoteDetailRoute on GoRouteData {
  static NoteDetailRoute _fromState(GoRouterState state) =>
      NoteDetailRoute(noteId: state.pathParameters['noteId']!);

  NoteDetailRoute get _self => this as NoteDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/notes/${Uri.encodeComponent(_self.noteId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $imageViewerRoute => GoRouteData.$route(
  path: '/image-viewer/:initialIndex',
  factory: $ImageViewerRoute._fromState,
);

mixin $ImageViewerRoute on GoRouteData {
  static ImageViewerRoute _fromState(GoRouterState state) => ImageViewerRoute(
    initialIndex: int.parse(state.pathParameters['initialIndex']!),
  );

  ImageViewerRoute get _self => this as ImageViewerRoute;

  @override
  String get location => GoRouteData.$location(
    '/image-viewer/${Uri.encodeComponent(_self.initialIndex.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
