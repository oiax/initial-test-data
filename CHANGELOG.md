# CHANGELOG - initial-test-data

## 0.3.0 (January 31, 2016)

* Monitor `app/models/**/*.rb`. When any modification is detected,
reinitialize the test data.
* The class method `InitialTestData.load` accepts `monitoring` option
to add the target directories of monitoring.

## 0.2.1 (January 31, 2016)

* Fix bug that the `_initial_data_digest` table gets truncated.

## 0.2.0 (January 31, 2016)

* The class method `InitialTestData.load` treats the last hash argument
as the options for `DatabaseCleaner.strategy=` method.

## 0.1.0 (January 31, 2016)

* The first release with minimum functionalities.