cls
@echo.
call gem build twb.gemspec
@echo.
call gem install %1%