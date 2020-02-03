import 'package:flutter/widgets.dart';
import 'package:flutter_youtube_player/models/player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:vsync_provider/vsync_provider.dart';

import 'app.dart';
import 'router.dart';

void run() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => Router()),
        VsyncProvider(),
        ChangeNotifierProvider(
          create: (context) => PlayerNotifier(
            tickerProvider: VsyncProvider.of(context),
          ),
        )
      ],
      child: const App(),
    ),
  );
}
