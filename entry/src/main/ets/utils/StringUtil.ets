import HiLog from "../utils/HiLog";

const TAG: string = "StringUtil";
const NON_ALPHABET_REG: RegExp = /[^\x00-\x80]/g;

class StringUtil {
  public countNonAlphabet(str: string): number {
    let match: RegExpMatchArray | null = str.match(NON_ALPHABET_REG);
    return (!match ? 0 : match.length);
  }

  public getOffsetForSession(page: number): number {
    let offset: number = 0;
    if (page < 3) {
      offset = (page - 1) * 50;
    } else {
      offset = (page - 2) * 100 + 50;
    }
    return offset;
  }

  public getLimitForSession(page: number): number {
    let limit: number = 0;
    if (page == 1) {
      limit = 50;
    } else {
      limit = 100;
    }
    return limit;
  }

  public getGroupIdsFromResultList(resultList): Array<number> {
    let groupIds: Array<number> = [];
    if (resultList != null) {
      for (let item of resultList) {
        if (item.groupId != null) {
          groupIds.push(item.groupId);
        }
      }
    }
    return groupIds;
  }
}

// Singleton
export default new StringUtil();