import { LengthMetrics } from '@kit.ArkUI';
import { SizeConstants } from '../constants/SizeConstants';
import { CHART_PAGE } from './ChartPage';
import { MOOD_PAGE } from './MoodPage';

export const HOME_PAGE = 'HomePage'

@Builder
export function HomePageBuilder() {
  HomePage();
}

@Component
struct HomePage {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    Scroll() {
      Column({ space: LengthMetrics.resource($r('app.float.margin_6')).value }) {
        Text($r('app.string.mood_logger'))
          .fontSize($r('app.float.header_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_primary_color'))
          .alignSelf(ItemAlign.Center)
        Button($r('app.string.select_mood'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_brand_color'))
          .backgroundColor($r('app.color.brand_color'))
          .width(SizeConstants.PERCENT_80)
          .onClick(() => {
            this.pageStack.pushPathByName(MOOD_PAGE, null);
          })
          .alignSelf(ItemAlign.Center)

        Button($r('app.string.weekly_chart'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_brand_color'))
          .backgroundColor($r('app.color.brand_color'))
          .width(SizeConstants.PERCENT_80)
          .onClick(() => {
            this.pageStack.pushPathByName(CHART_PAGE, null);
          })
          .alignSelf(ItemAlign.Center)
      }
      .height(SizeConstants.FULL_PERCENT)
      .width(SizeConstants.FULL_PERCENT)
      .padding($r('app.float.margin_20'))
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.background_color'))
    }
  }
}