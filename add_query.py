with open("entry/src/main/ets/store/RdbHelper.ets", "r") as f:
    content = f.read()

new_method = """  public async queryTodayTotalByType(userId: number, type: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const startOfDay = now.getTime();
    now.setHours(23, 59, 59, 999);
    const endOfDay = now.getTime();

    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId)
      .and()
      .equalTo('type', type)
      .and()
      .greaterThanOrEqualTo('timestamp', startOfDay)
      .and()
      .lessThanOrEqualTo('timestamp', endOfDay);
      
    let resultSet = await this.rdbStore.query(predicates, ['value']);
    let total = 0;
    while (resultSet.goToNextRow()) {
      total += resultSet.getLong(resultSet.getColumnIndex('value'));
    }
    resultSet.close();
    return total;
  }

"""

content = content.replace("  public async queryTodayWaterTotal", new_method + "  public async queryTodayWaterTotal")

with open("entry/src/main/ets/store/RdbHelper.ets", "w") as f:
    f.write(content)
