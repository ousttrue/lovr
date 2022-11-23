add_library(bit SHARED bit.c)
target_link_libraries(bit PRIVATE lua)
