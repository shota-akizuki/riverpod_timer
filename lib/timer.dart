import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_timer/timer_model.dart';

class TimerNotifier extends StateNotifier<TimerModel> {
  TimerNotifier() : super(_initialState);

  static const int _initialDuration = 10;
  static final _initialState = TimerModel(
      timeLeft: _durationString(_initialDuration),
      buttonState: ButtonState.initial);

  final Ticker _ticker = Ticker();
  StreamSubscription<int>? _tickerSubscription;

  static String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }

  void start() {
    //タイマーが一時停止している場合は、ストリームを再開してstate変数を更新する
    if (state.buttonState == ButtonState.paused) {
      _restartTimer();
    } else {
      _startTimer();
    }
  }

  void _restartTimer() {
    _tickerSubscription?.resume();
    state =
        TimerModel(timeLeft: state.timeLeft, buttonState: ButtonState.started);
  }

// それまでのストリームをキャンセルして、新しいストリームの受信を開始する
  void _startTimer() {
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick(ticks: _initialDuration).listen((duration) {
      state = TimerModel(
          timeLeft: _durationString(duration),
          buttonState: ButtonState.started);
    });

// onDoneコールバックを使用して、ストリームが終了したときに状態を更新する
    _tickerSubscription?.onDone(() {
      state = TimerModel(
          timeLeft: state.timeLeft, buttonState: ButtonState.finished);
    });
    state = TimerModel(
        timeLeft: _durationString(_initialDuration),
        buttonState: ButtonState.started);
  }

  void paused() {
    _tickerSubscription?.pause();
    state =
        TimerModel(timeLeft: state.timeLeft, buttonState: ButtonState.paused);
  }

  void reset() {
    _tickerSubscription?.cancel();
    state = _initialState;
  }
}

class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
