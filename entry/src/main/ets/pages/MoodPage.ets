import { BusinessError } from '@kit.BasicServicesKit';
import { KvStoreManager } from '../common/KvStoreManager';
import { SizeConstants } from '../constants/SizeConstants';
import Logger from '../utils/Logger';


export const MOOD_PAGE = 'MoodPage'

@Builder
export function MoodPageBuilder() {
  MoodPage();
}


@Component
struct MoodPage {
  @State selectedMood: string = '';
  @State statusMessage: ResourceStr = $r('app.string.feel_today');
  @State isSelected: boolean = false;
  private moods: Array<[string, string]> = [
    ['😃', 'Happy'],
    ['😐', 'Normal'],
    ['😢', 'Sad'],
    ['😡', 'Angry']
  ];

  aboutToAppear(): void {
    try {
      this.getDailyMood()
    } catch (e) {
      const error = e as BusinessError;
      Logger.error(`Failed to create KVManager. Code:${error.code}, message:${error.message}`);
      this.statusMessage = 'Database was not created!';
    }
  }

  saveStatusToLocalStorage(isSelected: boolean) {
    if (!KvStoreManager.getInstance().getStore()) {
      Logger.error('KVStore is not initialized. Cannot save mood.');
      this.statusMessage = 'Error: data is not saved!';
      return;
    }
    try {
      KvStoreManager.getInstance().getStore()!.put('status', isSelected)
        .then(() => {
          console.info(`Successfully saved isSelected: ${isSelected}`);
        })
        .catch((err: BusinessError) => {
          Logger.error(`Failed to save. Code: ${err.code}, message: ${err.message}`);
          this.statusMessage = 'Failed to save.';
        });
    } catch (e) {
      const error = e as BusinessError;
      Logger.error(`Unexpected error during save. Code:${error.code}, message:${error.message}`);
      this.statusMessage = 'Unexpected error during save.';
    }
  }

  private saveMoodToLocalStorage(mood: string): void {
    if (!KvStoreManager.getInstance().getStore()) {
      Logger.error('KVStore is not initialized. Cannot save mood.');
      this.statusMessage = 'Cannot save mood.';
      return;
    }

    const today = new Date().toISOString().split('T')[0];

    KvStoreManager.getInstance().getStore()!.get(today)
      .then((value) => {
        if (value) {
          this.statusMessage = `Your daily mood saved as: ${mood} 🎉`;
          this.isSelected = true;
        } else {
          KvStoreManager.getInstance().getStore()!.put(today, mood)
            .then(() => {
              console.info(`Successfully saved mood for ${today}: ${mood}`);
              this.statusMessage = `Your daily mood saved as: ${mood} 🎉`;
              this.isSelected = true;
              this.saveStatusToLocalStorage(true);
            })
            .catch((err: BusinessError) => {
              Logger.error(`Failed to save mood. Code: ${err.code}, message: ${err.message}`);
              this.statusMessage = 'Failed to save mood.';
            });
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(`Failed to get mood for today. Code: ${err.code}, message: ${err.message}`);
        if (err.code === 15100004) {
          KvStoreManager.getInstance().getStore()!.put(today, mood)
            .then(() => {
              console.info(`Successfully saved mood for ${today}: ${mood}`);
              this.statusMessage = `Your daily mood saved as: ${mood} 🎉`;
              this.isSelected = true;
              this.saveStatusToLocalStorage(true);
            })
            .catch((err: BusinessError) => {
              Logger.error(`Failed to save mood. Code: ${err.code}, message: ${err.message}`);
              this.statusMessage = 'Failed to save mood.';
            });
        } else {
          this.statusMessage = 'Failed to get data!';
        }
      }
      );
  }

  private getDailyMood() {
    const today = new Date().toISOString().split('T')[0];
    KvStoreManager.getInstance().getStore()!.get(today)
      .then((value) => {
        if (value) {
          this.statusMessage = `Your daily mood saved as: ${value} 🎉`;
          this.isSelected = true;
        } else {
          this.isSelected = false
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(`Failed to get mood for today. Code: ${err.code}, message: ${err.message}`);
        if (err.code === 15100004) {
          this.statusMessage = 'Select your mood!';
        } else {
          this.statusMessage =
            'Failed to get mood for today.';
        }
      });
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          Text(this.statusMessage)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 10, top: 20 })
            .fontColor($r('app.color.on_primary_color'))

          Row() {
            ForEach(this.moods, (item: [string, string]) => {
              Button() {
                Text(item[0]).fontSize(30)
              }
              .width(40)
              .height(40)
              .type(ButtonType.Circle)
              .backgroundColor(this.selectedMood === item[1] ? $r('app.color.brand_color') :
              $r('app.color.on_primary_color'))
              .shadow({ radius: 5, color: $r('app.color.primary_color') })
              .onClick(() => {
                this.selectedMood = item[1];
              })
            }, (item: [string, string]) => `${item[1]}`)
          }
          .width(SizeConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 5, right: 5 })

          if (this.isSelected) {
            Text('See you tomorrow!')
              .fontSize(16)
              .fontColor(Color.Gray)
              .margin({ top: 5 })
              .fontColor($r('app.color.on_primary_color'))
          }

          Button() {
            Text($r('app.string.select_mood'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_brand_color'))
          }
          .backgroundColor($r('app.color.brand_color'))
          .width(SizeConstants.PERCENT_80)
          .height(50)
          .shadow({ radius: 20, color: $r('app.color.primary_color') })
          .margin({ bottom: 10 })
          .enabled(!this.isSelected)
          .onClick(() => {
            if (this.selectedMood === '') {
              this.statusMessage = 'Please select mood.';
              return;
            }
            this.saveMoodToLocalStorage(this.selectedMood);
          })
        }
        .padding(20)
        .justifyContent(FlexAlign.Center)
        .width(SizeConstants.FULL_PERCENT)
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
    }
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
