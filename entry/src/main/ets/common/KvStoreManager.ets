import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';
import Logger from '../utils/Logger';

export class KvStoreManager {
  private static instance: KvStoreManager;
  private kvManager: distributedKVStore.KVManager | undefined = undefined;
  private kvStore: distributedKVStore.SingleKVStore | undefined = undefined;

  private constructor() {
  }

  public static getInstance(): KvStoreManager {
    if (!KvStoreManager.instance) {
      KvStoreManager.instance = new KvStoreManager();
    }
    return KvStoreManager.instance;
  }

  public async init(context: Context, bundleName: string, storeId: string): Promise<void> {
    if (this.kvStore) {
      return;
    }

    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: bundleName
    };

    try {
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);

      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      };

      this.kvStore = await new Promise((resolve, reject) => {
        this.kvManager?.getKVStore<distributedKVStore.SingleKVStore>(storeId, options, (err, store) => {
          if (err) {
            reject(err);
          } else {
            resolve(store);
          }
        });
      });
    } catch (e) {
      const error = e as BusinessError;
      Logger.error(`KVStoreManager init error. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  public getStore(): distributedKVStore.SingleKVStore | undefined {
    return this.kvStore;
  }
}
