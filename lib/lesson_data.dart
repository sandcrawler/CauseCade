import 'lesson.dart';
import 'course.dart';
import 'notification_service.dart'; //acces to class NetNotification


 List<Course> courseData = [
  new Course('Tutorial','01-07-2017'),
  new Course('Probability','11-10-2017'),
  new Course('Bayes Intro','11-10-2017'),
  new Course('Compared to other Networks','03-12-2017'),
  new Course('Applications in biology','03-12-2017')
];

void configureCourses(){
 Lesson lesson;

lesson = new Lesson('Tutorial - L1','26-09-2017')
..lessonDescription = 'Learning to navigate CauseCade'
..lessonMarkdownPath =  'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Tutorial_Pt_1.md'
..goals=([
 new NetNotification()..setTeachMode(),
 new NetNotification()..setNotificationDisplayStatus(true),
 new NetNotification()..setNodeDisplayMode("details"),
 new NetNotification()..setNewNetworkName()
]);
courseData[0].addLesson(lesson);

lesson = new Lesson('Tutorial - L2','26-09-2017')
..lessonDescription = 'Learning to load and manipulate a network'
..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Tutorial_Pt_2.md'
..goals=([
 new NetNotification()..setLoadMenuStatus(true),
 new NetNotification()..setLoadStatus("Animals"),
 new NetNotification()..setNodeSelectedDetail('Class'),
 new NetNotification()..setNodeSelectedDetail('WarmBlooded'),
 new NetNotification()..setNodeSelectedDetail('WarmBlooded')
]);
courseData[0].addLesson(lesson);

lesson = new Lesson('Tutorial - L3','27-09-2017')
 ..lessonDescription = 'Learning to manipulate individual nodes'
 ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Tutorial_Pt_3.md'
 ..goals=([
  new NetNotification()..setNodeAdderMenuStatus(true),
  new NetNotification()..setNewNode()
 ]);
courseData[0].addLesson(lesson);

 /*Course 2 -> Probability*/

 lesson = new Lesson('Probability - L1','11-10-2017')
..lessonDescription = 'Introduction to Probability'
..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Probability_Pt_1.md';
courseData[1].addLesson(lesson);

 lesson = new Lesson('Probability - L2','11-10-2017')
 ..lessonDescription = 'Understanding Conditional Probability'
 ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Probability_Pt_2.md';
courseData[1].addLesson(lesson);

/*Course 3 -> Bayes 1*/

 lesson = new Lesson('Preface','03-12-2017')
  ..lessonDescription = 'Introduction and Motivation for a bayesian network'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_0.md';
 courseData[2].addLesson(lesson);

lesson = new Lesson('Basic Bayes','11-10-2017')
..lessonDescription = 'understanding the use of bayes'
..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_1.md';
courseData[2].addLesson(lesson);

lesson = new Lesson('Basic Bayes 2','11-10-2017')
..lessonDescription = 'downward propagation in a 2 node system'
..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_2.md';
courseData[2].addLesson(lesson);

 lesson = new Lesson('Basic Bayes 3','11-10-2017')
  ..lessonDescription = 'upward propagation in a 2 node system'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_3.md';
 courseData[2].addLesson(lesson);

 lesson = new Lesson('Independence 1','11-10-2017')
  ..lessonDescription = 'Independence relationships in a bayesian network'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_4.md';
 courseData[2].addLesson(lesson);

 lesson = new Lesson('Independence 2','11-10-2017')
  ..lessonDescription = 'Independence relationships in a bayesian network'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_5.md';
 courseData[2].addLesson(lesson);

 lesson = new Lesson('Independence 3','03-12-2017')
  ..lessonDescription = 'Independence relationships in a bayesian network'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_6.md';
 courseData[2].addLesson(lesson);

 lesson = new Lesson('Bayes & Causality','03-12-2017')
  ..lessonDescription = 'Understanding Causality and directionality of a bayesnet'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Bayesian_Network_Pt_7.md';
 courseData[2].addLesson(lesson);

 /*Course 4 -> Compared to boolean*/

 lesson = new Lesson('Preface','03-12-2017')
  ..lessonDescription = 'Introduction'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Other_Networks_Pt_0.md';
 courseData[3].addLesson(lesson);

 /*Course 5 -> Applications in biology*/

 lesson = new Lesson('Preface','03-12-2017')
  ..lessonDescription = 'Introduction'
  ..lessonMarkdownPath = 'https://raw.githubusercontent.com/NemoAndrea/CauseCade-lessons/master/Applications_Biology_Pt_0.md';
 courseData[4].addLesson(lesson);

print('All Lessons configured in proper Courses');
}