import { common } from '@kit.AbilityKit';
import { KvStoreManager } from '../common/KvStoreManager';
import { BusinessError } from '@kit.BasicServicesKit';
import { MoodEnum, toMood } from '../common/MoodEnum';
import { SizeConstants } from '../constants/SizeConstants';
import Logger from '../utils/Logger';
import {
  ComponentContent,
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  LengthMetrics,
} from '@kit.ArkUI';

interface WeeklyMood {
  date: string;
  mood: string;
  moodEnum: MoodEnum.DEFAULT;
}

export const CHART_PAGE = 'ChartPage'

@Builder
export function ChartPageBuilder() {
  ChartPage();
}

@Builder
function buildHeader() {
  Text($r('app.string.weekly_mood_title'))
    .width(SizeConstants.PERCENT_80)
    .fontSize($r('app.float.header_font_size'))
    .fontColor($r('app.color.on_primary_color'))
    .fontWeight(FontWeight.Bold)
    .textAlign(TextAlign.Center)
    .margin({ bottom: 10, top: 10 })
}

@Component
struct ChartPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State weeklyMoodList: Array<WeeklyMood> = [];
  private headerComponent: ComponentContent<Object> =
    new ComponentContent<Object>(this.getUIContext(), wrapBuilder(buildHeader));

  aboutToAppear(): void {
    KvStoreManager.getInstance()
      .init(this.context, this.context.abilityInfo.bundleName, 'moodStore')
      .then(() => {
        this.getLast7DaysMood().then((data) => {
          this.weeklyMoodList = data;
        });
      })
      .catch((err: BusinessError) => {
        Logger.error('KVStore init error:', err.message);
      });
  }

  async getLast7DaysMood(): Promise<Array<WeeklyMood>> {
    const kvStore = KvStoreManager.getInstance().getStore();
    if (!kvStore) {
      return [];
    }


    const result: Array<WeeklyMood> = [];
    const today = new Date();

    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(today.getDate() - i);
      const dateKey = date.toISOString().split('T')[0];

      try {
        const mood = await kvStore.get(dateKey);
        result.push({
          date: dateKey,
          mood: mood.toString() ?? '-',
          moodEnum: toMood(mood.toString())
        } as WeeklyMood);
      } catch {
        result.push({
          date: dateKey,
          mood: '-',
          moodEnum: MoodEnum.DEFAULT
        } as WeeklyMood);
      }
    }
    return result.reverse();
  }

  private getMoodColor(mood: MoodEnum): Color {
    console.log(`MoodEnum:: ${mood}`)
    switch (mood) {
      case MoodEnum.HAPPY:
        return Color.Green;
      case MoodEnum.SAD:
        return Color.Blue;
      case MoodEnum.ANGRY:
        return Color.Red;
      case MoodEnum.NORMAL:
        return Color.Gray;
      default:
        return Color.Black;
    }
  }

  build() {
    NavDestination() {
      ArcList({ header: this.headerComponent }) {
        ForEach(this.weeklyMoodList, (item: WeeklyMood) => {
          ArcListItem() {
            Row({ space: 12 }) {
              Text(item.date).fontSize($r('app.float.list_item_font_size'))
              Text(item.mood)
                .constraintSize({ minWidth: 20, minHeight: 20 })
                .padding({
                  left: $r('app.float.margin_8'),
                  top: $r('app.float.margin_4'),
                  right: $r('app.float.margin_8'),
                  bottom: $r('app.float.margin_4')
                })
                .fontSize($r('app.float.list_item_font_size'))
                .fontWeight(FontWeight.Bold)
                .backgroundColor(this.getMoodColor(item.moodEnum))
                .borderRadius($r('app.float.margin_16'))
            }
            .width(SizeConstants.FULL_PERCENT)
            .backgroundColor($r('app.color.primary_color'))
            .borderRadius($r('app.float.margin_16'))
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({
              left: $r('app.float.margin_12'),
              top: $r('app.float.margin_8'),
              right: $r('app.float.margin_12'),
              bottom: $r('app.float.margin_8')
            })
            .align(Alignment.Start)
          }
          .width(SizeConstants.PERCENT_86)
        }, (item: WeeklyMood) => item.date)
      }
      .space(LengthMetrics.resource($r('app.float.margin_8')))
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
    }
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
