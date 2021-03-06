// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import '../example_app.dart';
import 'package:angular2/core.dart';
import 'package:logging/logging.dart';
import 'package:angular2/common.dart';
import 'package:fnx_ui/src/components/modal/fnx_modal.dart';
import 'package:fnx_ui/src/components/app/fnx_app.dart';
import '../example_buttons_renderer.dart';

@Component(
    selector: 'cookbook-table',
    templateUrl: 'cookbook_table.html',
    directives: const [ExampleButtonsRenderer]
)
class CookbookTable {

  ExampleApp app;

  String search = null;

  CookbookTable(this.app);

  ngOnInit() {
    loadMore();
  }

  Iterable get list {
    if (search == null) return app.list;
    return app.list.where(containsSearch);
  }

  bool containsSearch(Map<String,String> row) {
    return row["name"].contains(search) || row["email"].contains(search);
  }

  void loadMore() {
    app.loadMore();
  }


}
