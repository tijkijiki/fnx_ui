import 'package:angular2/core.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:fnx_ui/src/util/ui.dart' as ui;
import 'dart:async';
import 'package:fnx_ui/src/util/date.dart';
import 'dart:html';

@Component(
    selector: 'fnx-date-picker',
    templateUrl: 'fnx_date_picker.html'
)
class FnxDatePicker implements OnInit, OnDestroy {

  String componentId = ui.uid('datepicker-');


  static Set<FnxDatePicker> allPickers = new Set.from([]);

  bool _shown = false;

  @Input()
  String label;

  DateTime _value;
  DateTime _originalValue;

  @Input() bool hourFormat24 = true;
  @Input() bool dateTime = false;

  List days;

  @Output() EventEmitter closed = new EventEmitter();
  @Output() EventEmitter datePicked = new EventEmitter();

  DateTime today = new DateTime.now();

  DateTime get value => _value;

  /// Constructor used to create instance of Datepicker.
  FnxDatePicker() {
    initPicker();
  }

  @Input()
  set value(var date) {
    valueInternal = date;
    _originalValue = _value;
  }

  set valueInternal(var date) {
    if (date != null && !(date is DateTime)) return;
    _value = date as DateTime;
    valueChanged();
  }

  @Input()
  set shown(bool toShow) {
    bool alreadyShown = _shown;
    this._shown = toShow;
    if (toShow && !alreadyShown) {
      allPickers.forEach((dp) {
        if (dp != this) {
          dp.hidePicker();
        }
      });
    }
  }

  bool get shown => _shown;

  int get year => _value.year;
  int get month => _value.month;
  int get day => _value.day;

  int get hour => _value.hour;
  int get minute => _value.minute;

  int get hourToShow {
    if (hourFormat24) {
      return hour;
    } else {
      return hour24ToAmPm(hour).hour;
    }
  }

  AmPm get amPm => amOrPm(hour);

  void valueChanged() {
    initPicker();
  }

  initPicker() {
    if (_value == null) {
      _value = today;
    }
    initPickerModel();
  }

  initPickerModel() {
    DateTime ref = new DateTime.utc(year, month, 1);
    List result = [];
    for (int a = 0; a < 6; a++) {
      result.add([]);
      for (int b = 0; b < 7; b++) {
        result[a].add(" ");
        if (ref.month == month) {
          if (ref.weekday - 1 == b) {
            result[a][b] = ref.day;
            ref = ref.add(new Duration(days: 1));
          }
        }
      }
    }
    days = result;
  }

  bool isSelected(int year, int month, int day) {
    if (_originalValue == null) return false;
    return  _originalValue.year == year &&
            _originalValue.month == month &&
            _originalValue.day == day;
  }

  String renderToday() {
    return new DateFormat("dd.MM.yyyy").format(today);
  }

  void pickDay(int year, int month, int day) {
    datePicked.emit(new DateTime(year, month, day, _value.hour, _value.minute));
    hidePicker();
  }

  void hidePicker() {
    _shown = false;
    closed.emit(true);
  }

  void formatNumber(int num) {
    if (num == null) return null;
    var formatter = new NumberFormat('00');
    return formatter.format(num);
  }

  void incMinute() {
    addDurationToValue(new Duration(minutes: 1));
  }

  void decMinute() {
    subtractDurationFromValue(new Duration(minutes: 1));
  }

  void incHour() {
    addDurationToValue(new Duration(hours: 1));
  }

  void decHour() {
    subtractDurationFromValue(new Duration(hours: 1));
  }

  void incMonth() {
    changeValueMonth(1);
  }

  void decMonth() {
    changeValueMonth(-1);
  }

  void incYear() {
    changeValueMonth(12);
  }

  void decYear() {
    changeValueMonth(-12);
  }

  void showToday() {
    int h, m, s, ms = 0;
    bool utc = today.isUtc;
    if (value != null) {
      h = value.hour;
      m = value.minute;
      s = value.second;
      ms = value.millisecond;
      utc = value.isUtc;
    }
    valueInternal = dateFrom(today.year, today.month, today.day, h, m, s, ms, utc);
  }

  void changeValueMonth(int by) {
    if (value == null) return;
    int month = value.month;
    int year = value.year;
    int yearsChange = (by / 12).floor();
    int monthsChange = by % 12;

    // we intentionally do not emit datePicked event, since this signals that the picker
    // should rerender, not that new value has been picked
    valueInternal = dateFrom(year + yearsChange, month + monthsChange, value.day, value.hour, value.minute, value.second, value.millisecond, value.isUtc);
  }

  void addDurationToValue(Duration dur) {
    valueInternal = _value.add(dur);
    datePicked.emit(_value);
  }

  void subtractDurationFromValue(Duration dur) {
    valueInternal = _value.subtract(dur);
    datePicked.emit(_value);
  }

  bool get isAm => AmPm.AM == amPm;
  bool get isPm => AmPm.PM == amPm;

  void setPm() {
    var h = hour24ToAmPm(hour).hour;
    int convertedHour = hourAmPmTo24(new AmPmHour(h, AmPm.PM));
    valueInternal = setHour(_value, convertedHour);
    datePicked.emit(_value);
  }

  void setAm() {
    var h = hour24ToAmPm(hour).hour;
    int convertedHour = hourAmPmTo24(new AmPmHour(h, AmPm.AM));
    valueInternal = setHour(_value, convertedHour);
    datePicked.emit(_value);
  }

  @override
  ngOnInit() {
    allPickers.add(this);
  }

  @override
  ngOnDestroy() {
    allPickers.remove(this);
  }

  void killEvent(Event event) {
    ui.killEvent(event);
  }
}