# Changelog for hey-you gem
## 1.3.1/1.3.2/1.3.3/1.3.4
Fixing bugs

## 1.3.0
- Feature: `body_part` in email builder.

### 1.2.3
- Improvement: fix ruby 2.7 warnings
- Fix: fix `NoMethodError` in `sender.rb` when channel must be ignored by `if` 

### 1.2.2
- Improvement: `if` condition for receiver (if condition `false` - sending will be skipped).
- Improvement: `force` option - send message independent on `if` condition.


### 1.2.1
- Improvement: Builder will not make channel builder if it skipped by only option

### 1.2.0
- Feature: data source extensions (check readme for more information). 
__Attention__: You should rewrite your configuration for use yaml data source! 
