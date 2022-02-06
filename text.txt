# How to Treat CMake as a Package Manager

There are three ways to access a project from another CMake project:
1. A project is installed  (e.g. /usr/local/lib/libFoo.so)
2. A project is a subdirectory of another (e.g. ```add_subdirectory(spotrflow)```)
3. A project is exported through CMake (e.g. ```export(TARGETS spotrflow_protobuf spotrflow_types NAMESPACE SpotrFlow:: FILE SpotrFlowTargets.cmake)```)

#@ How do we want to include these libraries?

Traditionally for including system libraries, we would use the syntax
```find_package(Boost REQUIRED)```and this usually works. To unveil the magic of
this, CMake comes with the box a FindBoost.cmake that handles the process of
finding Boost libraries and headers. Where we can link boost to our target by
```target_link_libraries(Perception PRIVATE Boost::boost)```. This also applies to several more common
third-party software (e.g. ALSA, BISON, Doxygen). Generally, treat system
packages as if they work out of the box.

Applying the similar idea of if we had a dependency as a subdirectory, we would first add the subdirectory with ```add_subdirectory(spotrflow)``` 
and we would link the dependency with ```target_link_libraries(Perception PRIVATE SpotrFlow::spotrflow_protobuf SpotrFlow::spotrflow_types)```. 
This syntax "namespace" syntax can be accomplished
when the subproject has declared an alias with ```add_library(SpotrFlow::SpotrFlow ALIAS spotrflow)```. If our subproject was super nice,
it would group up all the targets into one big target *note* **FIGURE OUT** *note*
so we could do ```target_link_libraries(Perception PRIVATE SpotrFlow::SpotrFlow)```. Generally, subprojects need to
disable their version of find_project(Foo) since it should be handled by
top-level CMakeList and alias their library target.

For exporting a project to be aware for CMake users, CMake also looks for a
<Package>Config.cmake that is auto-generated (e.g. BoostConfig.cmake if Boost wasn't already handled).
This method unifies the above two methods together because CMake has the idea of
"Generators" which generate paths whether we are installing our dependency as a system package through ```make install```, which is
handled on the first paragraph. Generators can also be used on build targets
where we were using a dependency as a subdirectory of our project. Either way,
we can follow the same desired syntax of ```target_link_libraries(Perception PRIVATE SpotrFlow::SpotrFlow)```. Generally, exported
projects should be installed into a consistent <prefix> location and make use of
Generators.

Top-level of super-project
```
# "prefix" refers to where we are installing our exported packages (like /usr/local/lib or /prefix in this case)
set(CMAKE_PREFIX_PATH "/prefix") 
# we list out projects we are using as a subproject through add_subdirectory()
set(as_subproject Foo)

# override cmake's find_package()
macro(find_package)
  if(NOT "${ARG0}" IN_LIST as_subproject)
    _find_package(${ARGV}) # call cmake's version of find_package()
  endif()
endmacro()

add_subdirectory(Foo)

```

## How this idea integrates with our build process?

Our current way of using a docker container to build a project and copy over
files is a unique idea. We can make this work by having the docker container
build the subproject and "installing" to some common prefix that we can all copy
from.

Imagine:
/leap/
  |
  - bin/
  |
  - include/
     |
     SpotrFlow/*.h
  |
  - lib/
     |
     CMake/
       |
       SpotrFlow/SpotrFlowConfig.cmake
     |
     libspotrflow_protobufs.so
     |
     libspotrflow_types.so

https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-to-create-a-ProjectConfig.cmake-file
https://www.youtube.com/watch?v=bsXLMQ6WgIk

NOTE:
how to group up targetswith target_link_libraries()
