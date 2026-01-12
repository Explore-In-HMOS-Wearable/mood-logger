import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { KvStoreManager } from '../common/KvStoreManager';
import { HomePageBuilder, HOME_PAGE } from './HomePage';
import { MoodPageBuilder, MOOD_PAGE } from './MoodPage';
import { ChartPageBuilder, CHART_PAGE } from './ChartPage';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  reminderTitle: string = 'Mood Logger';
  reminderContent: string = 'Select your mood';
  reminderTime: number = 5;
  showInputForm: boolean = false;
  notificationId: number = 1000;

  aboutToAppear() {
    this.openNotificationPermission();
    this.createReminder();
    KvStoreManager.getInstance().init(this.context, this.context.abilityInfo.bundleName, 'moodStore')
  }

  @Builder
  PageMap(name: string) {
    if (name === HOME_PAGE) {
      HomePageBuilder();
    } else if (name === MOOD_PAGE) {
      MoodPageBuilder();
    } else if (name === CHART_PAGE) {
      ChartPageBuilder();
    }
  }

  build() {
    Navigation(this.pageStack) {
      HomePageBuilder()
    }
    .width($r('app.float.px_watch_size'))
    .height($r('app.float.px_watch_size'))
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .navDestination(this.PageMap)
  }

  private openNotificationPermission() {
    notificationManager.requestEnableNotification(this.context).then(() => {
      Logger.info('Enable notification success');
    }).catch((err: Error) => {
      Logger.error(`Enable notification failed because ${err.message}`);
    });
  }

  private createReminder() {
    Logger.info('createReminder() started');

    const timeInSeconds = this.reminderTime;
    if (isNaN(timeInSeconds) || timeInSeconds <= 0) {
      Logger.info('Invalid time input');
      return;
    }

    if (!this.reminderTitle || !this.reminderContent) {
      Logger.info('Title or content missing');
      return;
    }

    let timerReminder: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: timeInSeconds,
      title: this.reminderTitle,
      content: this.reminderContent,
      notificationId: ++this.notificationId,
      wantAgent: {
        pkgName: this.context.abilityInfo.bundleName,
        abilityName: 'EntryAbility',
        uri: 'pages/Index'
      },
      ringDuration: 3
    };

    Logger.info(`Publishing reminder with ID: ${this.notificationId}`);

    reminderAgentManager.publishReminder(timerReminder).then((id: number) => {
      Logger.info(`Reminder published successfully with request ID: ${id}`);
      this.showInputForm = false;
      this.reminderTitle = '';
      this.reminderContent = '';
      this.reminderTime = 0;
    }).catch((err: BusinessError) => {
      Logger.info(`Failed to publish reminder: ${err.code}, ${err.message}`);
    });
  }
}
