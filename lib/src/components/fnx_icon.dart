import 'package:angular/angular.dart';

@Component(
    selector: 'fnx-icon',
    template: r'''
<i class="icon">{{ type }}</i>
''',
    preserveWhitespace: false
)
class FnxIcon {

  @Input() String type;
}

const FNX_ICON_DIRECTIVES = const [FnxIcon];