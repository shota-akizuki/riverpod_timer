class TimerModel {
  const TimerModel({required this.timeLeft, required this.buttonState});
  final String timeLeft;
  final ButtonState buttonState;
}

enum ButtonState {
  initial,
  started,
  paused,
  finished,
}

// timeLeftが整数ではなく文字列であることに驚くかもしれません。
// 後で残り時間を管理するときには、確かに内部的には整数を使うことになります。
// しかし、TimerModelの目的は、UIが直接表示できるようにすべてを準備することです。
// その理由は、UIにできるだけロジックを入れたくないからです。
// もしUIに整数を渡した場合、UIはその整数を表示可能な文字列にフォーマットするために何らかのロジックを使用しなければなりません。
// その代わりに、自分で整数を事前にフォーマットして、UIに必要なものだけを渡すようにします。
