//This Component will hold the navigation and progress information for the
// CauseCade course (educational) part

import 'package:angular2/core.dart';
import 'package:angular_components/angular_components.dart';
import 'package:causecade/app_component.dart';
import 'package:causecade/course_lesson_component.dart';
import 'package:causecade/teach_service.dart';
import 'package:causecade/course.dart';
import 'package:causecade/lesson.dart';
import 'lesson_data.dart'; //FIX
import 'package:causecade/notification_service.dart';

@Component(
    selector: 'course-navigator',
    templateUrl: 'course_navigator_component.html',
    styleUrls: const ['course_navigator_component.css'],
    directives: const [materialDirectives,CourseLessonComponent ], //
    providers: const [materialProviders])

class CourseNavigatorComponent {
  @Input()
  bool isActive;
  bool lessonSelected;

  TeachService teachService;
  NotificationService notifications;

  int navigationRatio =12;  //What fraction of window should the navigation
                            //header be? (percentage)
  int navigationRatioComplement;
  Course CourseSelect; //selected course
  List<Lesson> LessonList;

  //bool =true; //any lesson selected?

  CourseNavigatorComponent(this.teachService,this.notifications){/*this._teachService*/
    print('[Course Navigator Component] loaded...');
    navigationRatioComplement=100-navigationRatio;
    LessonList = new List<Lesson>();
  }


  void openCourseMenu(){
    isActive=true;
    print('User Opened Course Navigator');
  }

  void selectCourse(Course courseIn){
    CourseSelect = courseIn; //set currently Selectd Course
    LessonList=CourseSelect.courseLessons; //find lessons (only) of this course
  }

  /*void selectLesson(Lesson lessonIn){
    _teachService.currentLesson = lessonIn;
  }

  test_set(){ //fix
    _teachService.currentLesson = CourseList[0].courseLessons[0];
  }

  test_clear(){ //fix
    _teachService.clearCurrentLesson();
  }*/

  // Dropdowns (course)

  SelectionModel<Course> targetCourseSelection =
    new SelectionModel.withList();/*..selectionChanges.listen(updateCourse);*/

  StringSelectionOptions<Course> get courseOptionsLong => new StringSelectionOptions<Course>(teachService.getCourses().courseList);

  static final ItemRenderer<Course> courseNameRenderer =
      (HasUIDisplayName course) => course.uiDisplayName;

 /* String get selectedCourseName {
    if(  targetCourseSelection.selectedValues.isNotEmpty){
        return targetCourseSelection.selectedValues.first.uiDisplayName;
    }
    else {
      return 'No Course Selected';
    }
  }*/

  String get selectedCourseLabel {
    if(  targetCourseSelection.selectedValues.isNotEmpty){
      CourseSelect=targetCourseSelection.selectedValues.first;
      LessonList = CourseSelect.courseLessons;
      return targetCourseSelection.selectedValues.first.uiDisplayName;
    }
    else {
      CourseSelect=null;
      LessonList = new List<Lesson>();
      return 'Choose a course module';
    }
  }
// Dropdowns (Lesson)


  SelectionModel<Lesson> targetLessonSelection =
  new SelectionModel.withList();

  StringSelectionOptions<Lesson> get lessonOptionsLong => new StringSelectionOptions<Lesson>(LessonList);

  static final ItemRenderer<Lesson> lessonNameRenderer =
      (HasUIDisplayName lesson) => lesson.uiDisplayName;

 /* String get selectedLessonName =>
      targetLessonSelection.selectedValues.isNotEmpty
          ? targetLessonSelection.selectedValues.first.uiDisplayName
          : 'No Lesson Selected';*/

  String get selectedLessonLabel {
    if(targetLessonSelection.selectedValues.length > 0){
      teachService.currentLesson=targetLessonSelection.selectedValues.first;
      teachService.currentCourse=CourseSelect;
      //print(_teachService.currentLesson.lessonName);
      //lessonSelected=true;

      return (targetLessonSelection.selectedValues.first.uiDisplayName);
    }
    else {
      //lessonSelected=false;
      teachService.clearCurrentLesson();
      teachService.clearCurrentCourse();
      return 'Choose a lesson';
    }
  }

  void prevLesson(){
    //if we have a lesson selected and it is not the first in the list
    if((teachService.currentLesson!=null) && LessonList.indexOf(teachService.currentLesson)!=0){
      targetLessonSelection.select(LessonList[(LessonList.indexOf(teachService.currentLesson)-1)]);
      //print('Prev Lesson');
    }
  }

  void nextLesson(){
    //if we have a lesson selected and it is not the last in the list
    if((teachService.currentLesson!=null)  && LessonList.indexOf(teachService.currentLesson)!=LessonList.length-1){
      targetLessonSelection.select(LessonList[(LessonList.indexOf(teachService.currentLesson)+1)]);
      //print('Next Lesson');
    }
  }
}