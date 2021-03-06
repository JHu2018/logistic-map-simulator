import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:quiver/async.dart';
import 'package:intl/intl.dart';

class PopulationSimulation extends StatefulWidget {
  @override
  _PopulationSimulationState createState() => _PopulationSimulationState();
}

/// Population simulator
class _PopulationSimulationState extends State<PopulationSimulation> {
  final List<List<double>> _progressLog = <List<double>>[[]];
  double _r = 1.0;
  double _x0 = 0.5;
  bool _isRunning = false;
  int _currIdx = 0;
  final int _iterations = 20;
  bool _isRunOnce = false;

  void initState() {
    super.initState();
    buildStartProgress(_x0);
  }

  void buildStartProgress(x) {
    final gen = Random();
    final List<double> currProgress = <double>[];

    for (var i = 0; i < 10; i++) {
      final v = x + gen.nextDouble() * 0.01;
      currProgress.add(max(0, min(1, v)));
    }

    _progressLog.clear();
    _progressLog.add(currProgress);
  }

  void startTimer() {
    final int interval = 100;

    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(milliseconds: _iterations * interval),
      new Duration(milliseconds: interval),
    );

    setState(() {
      _isRunning = true;
      buildStartProgress(_x0);
      _currIdx = 0;
    });

    final sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        var prevProgress = _progressLog[_progressLog.length - 1];
        var currProgress = <double>[];
        for (var i = 0; i < prevProgress.length; i++) {
          currProgress.add(_r * prevProgress[i] * (1 - prevProgress[i]));
        }
        _progressLog.add(currProgress);
        _currIdx++;
      });
    });

    sub.onDone(() {
      setState(() {
        _isRunning = false;
        _isRunOnce = true;
      });
      sub.cancel();
    });
  }

  Widget renderControl() {
    if (!_isRunning) {
      return Column(
        children: <Widget>[
          _isRunOnce
              ? Row(
                  children: <Widget>[
                    const Text('Playback:'),
                    Expanded(
                      child: Slider(
                        value: _currIdx / _iterations,
                        onChanged: (x) {
                          setState(() {
                            _currIdx = (x * _iterations).round();
                          });
                        },
                      ),
                    )
                  ],
                )
              : Container(),
          Container(
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text("r:",
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.5)),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 100.0,
                    maxHeight: 50.0,
                    minWidth: 100.0,
                    minHeight: 50.0,
                  ),
                  child: TextField(
                    controller: TextEditingController(text: '$_r'),
                    onChanged: (String value) {
                      final v = double.tryParse(value);
                      if (v != null && v <= 4 && v >= 0) {
                        _r = double.tryParse(value);
                      }
                    },
                  ),
                ),
                Text("x\u2080:",
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.5)),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 100.0,
                    maxHeight: 50.0,
                    minWidth: 100.0,
                    minHeight: 50.0,
                  ),
                  child: TextField(
                    controller: TextEditingController(text: '$_x0'),
                    onChanged: (String value) {
                      final v = double.tryParse(value);
                      if (v != null && v <= 1 && v >= 0) {
                        _x0 = double.tryParse(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          RaisedButton(
            onPressed: () {
              if (!_isRunning) startTimer();
            },
            child: const Text('Run Simulation'),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          _PopulationBars(_progressLog[_currIdx]),
          renderControl(),
        ],
      ),
    );
  }
}

/// Renders population bars
class _PopulationBars extends StatelessWidget {
  final List<double> _progress;

  _PopulationBars(this._progress);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: this._progress.length,
        itemBuilder: (context, i) {
          final formatter = NumberFormat('0.00');

          return Container(
            margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(right: 5.0),
                  child: Text(formatter.format(this._progress[i])),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: this._progress[i].toDouble(),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green[300]),
                    backgroundColor: Colors.grey[300],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
