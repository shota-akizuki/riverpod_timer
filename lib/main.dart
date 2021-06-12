import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_timer/timer.dart';
import 'timer_model.dart';
import 'timer.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) => TimerNotifier(),
);

// refという引数はProviderReference型で、他のプロバイダにアクセスすることができる
// 以前作成した timerProvider への参照を与える
final _buttonState = Provider<ButtonState>((ref) {
  return ref.watch(timerProvider).buttonState;
});

// watchは、ユニークな変更に対してのみ更新を行う

final buttonProvider = Provider<ButtonState>((ref) {
  return ref.watch(_buttonState);
});

final _timeLeftProvider = Provider<String>((ref) {
  return ref.watch(timerProvider).timeLeft;
});

final timeLeftProvider = Provider<String>((ref) {
  return ref.watch(_timeLeftProvider);
});

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('building MyHomePage');
    return Scaffold(
      appBar: AppBar(
        title: Text("Timer App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TimerTextWidget(),
            SizedBox(height: 20),
            ButtonContainer()
          ],
        ),
      ),
    );
  }
}

class ButtonContainer extends HookWidget {
  const ButtonContainer({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('building ButtonsContainer');
    final state = useProvider(buttonProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state == ButtonState.initial) ...[
          StartButton(),
        ],
        if (state == ButtonState.started) ...[
          PauseButton(),
          SizedBox(width: 20),
          ResetButton(),
        ],
        if (state == ButtonState.paused) ...[
          StartButton(),
          SizedBox(width: 20),
          ResetButton(),
        ],
        if (state == ButtonState.finished) ...[
          ResetButton(),
        ],
      ],
    );
  }
}

class PauseButton extends StatelessWidget {
  const PauseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read(timerProvider.notifier).paused();
      },
      child: Icon(
        Icons.pause,
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read(timerProvider.notifier).reset();
      },
      child: Icon(
        Icons.replay,
      ),
    );
  }
}

class StartButton extends StatelessWidget {
  const StartButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read(timerProvider.notifier).start();
      },
      child: Icon(Icons.play_arrow),
    );
  }
}

class TimerTextWidget extends HookWidget {
  const TimerTextWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // useProviderメソッドは、TimerModelへの参照を与え、モデルの変更を監視する
    // 変更があった場合、buildメソッドは新しい状態でウィジェットを再構築する
    final timeLeft = useProvider(timeLeftProvider);
    print('building TimerTextWidget $timeLeft');
    return Text(
      timeLeft,
      style: Theme.of(context).textTheme.headline4,
    );
  }
}
