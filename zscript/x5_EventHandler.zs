// SPDX-FileCopyrightText: 2019-2020, 2022-2023 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class x5_SpawnPoint
{
  Vector3 position;
  double height;
  double radius;
  Class<Actor> replaceeType;
  Actor replacee;
}

class x5_EventHandler : EventHandler
{

  // There are mods that have randomization that takes a few tics.
  const TIME_TO_RANDOMIZE = 4;

  override void WorldLoaded(WorldEvent event)
  {
    mGlobalMultiplier = x5_multiplier;
    mMultiplyTime     = 0;

    collectSpawnPoints(mSpawnPoints);
    mEnemyTypes = collectEnemyTypes(mSpawnPoints);

    if (mGlobalMultiplier == 0)
    {
      // Each enemy type has its own multiplier, ask to fill multipliers.
      mIsWaitingForTypeMultipliersMenu = (consolePlayer == net_arbitrator);
    }
    else
    {
      // The global multiplier is used for all enemy types.
      mTypeMultipliers = fillTypeMultipliers(mEnemyTypes, mGlobalMultiplier);
    }
  }

  private
  static void collectSpawnPoints(out Array<x5_SpawnPoint> result)
  {
    Actor anActor;
    for (let i = ThinkerIterator.Create("Actor"); anActor = Actor(i.Next());)
    {
      let replaceeType = Actor.getReplacee(anActor.getClassName());

      if (!isCloneable(getDefaultByType(replaceeType))) { continue; }

      let spawnPoint          = new ("x5_SpawnPoint");
      spawnPoint.position     = anActor.pos;
      spawnPoint.height       = anActor.height;
      spawnPoint.radius       = anActor.radius;
      spawnPoint.replaceeType = replaceeType;
      spawnPoint.replacee     = anActor;
      result.Push(spawnPoint);
    }
  }

  private
  static Dictionary collectEnemyTypes(Array<x5_SpawnPoint> spawnPoints)
  {
    let result = Dictionary.Create();
    foreach (spawnPoint : spawnPoints)
    {
      result.Insert(spawnPoint.replaceeType.GetClassName(), "");
    }
    return result;
  }

  private
  static Dictionary fillTypeMultipliers(Dictionary enemyTypes, int multiplier)
  {
    let result              = Dictionary.Create();
    let formattedMultiplier = String.Format("%d", multiplier);
    for (let i = DictionaryIterator.Create(enemyTypes); i.Next();)
    {
      result.Insert(i.Key(), formattedMultiplier);
    }
    return result;
  }

  override void UiTick()
  {
    if (mIsWaitingForTypeMultipliersMenu && !mIsTypeMultipliersMenuOpened)
    {
      mIsTypeMultipliersMenuOpened = true;
      openTypeMultipliersMenu();
    }
  }

  private
  ui void openTypeMultipliersMenu()
  {
    let descriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("x5_TypeMultipliers"));
    descriptor.mItems.clear();

    for (let i = DictionaryIterator.Create(mEnemyTypes); i.Next();)
    {
      Class<Actor> enemyClass = i.Key();
      let defaultEnemy        = getDefaultByType(enemyClass);
      let slider              = new ("OptionMenuItemX5TypeSlider");
      slider.Init(enemyClass, defaultEnemy.getTag());
      descriptor.mItems.push(slider);
    }

    Menu.SetMenu("x5_TypeMultipliers");
    x5_TypeMultipliersMenu(Menu.GetCurrentMenu()).setEventHandler(self);
  }

  private
  int mGlobalMultiplier;
  private
  bool mIsWaitingForTypeMultipliersMenu;
  private
  ui bool mIsTypeMultipliersMenuOpened;
  private
  Dictionary mEnemyTypes;
  private
  Dictionary mTypeMultipliers;
  private
  int mMultiplyTime;
  private
  Array<x5_SpawnPoint> mSpawnPoints;

  override void WorldTick()
  {
    // wait for type multipliers.
    if (mTypeMultipliers == NULL) { return; }

    if (level.maptime > TIME_TO_RANDOMIZE)
    {
      multiply();
      mMultiplyTime = level.maptime;
    }
    else if (level.maptime > mMultiplyTime + TIME_TO_RANDOMIZE)
    {
      nudgeCloned();
      destroy();
    }
  }

  override void NetworkProcess(ConsoleEvent event)
  {
    if (event.name.left(3) != "x5_") { return; }

    mTypeMultipliers = Dictionary.FromString(event.name.Mid(3));
  }

  private
  void multiply()
  {
    for (let i = DictionaryIterator.Create(mTypeMultipliers); i.Next();)
    {
      int multiplier = i.Value().ToInt();
      if (multiplier == 100) { continue; }

      Array<Actor> enemiesByType;
      collectSpawnedEnemiesByType(i.Key(), enemiesByType);
      multiplyEnemies(enemiesByType, multiplier);
    }
  }

  private
  void collectSpawnedEnemiesByType(Class<Actor> type, out Array<Actor> enemiesByType)
  {
    foreach (spawnPoint : mSpawnPoints)
    {
      if (spawnPoint.replaceeType != type) { continue; }

      // If the actor is still present, great! Otherwise, assume the spawned actor isn't far away.
      if (spawnPoint.replacee != NULL) { enemiesByType.Push(spawnPoint.replacee); }
      else
      {
        let pos    = spawnPoint.position;
        let height = spawnPoint.height;
        let radius = spawnPoint.radius;
        let i      = BlockThingsIterator.CreateFromPos(pos.x, pos.y, pos.z, height, radius, false);

        if (i.Next()) { enemiesByType.Push(i.thing); }
      }
    }
  }

  private
  void multiplyEnemies(Array<Actor> enemies, int multiplier)
  {
    if (multiplier == 100) { return; }

    int integerMultiplier = multiplier / 100;
    int copiesNumber      = integerMultiplier - 1;
    foreach (enemy : enemies)
    {
      if (multiplier == 0) { enemy.GiveInventory("x5_Killer", 1); }
      else
      {
        for (int c = 0; c < copiesNumber; ++c)
        {
          clone(enemy);
        }
      }
    }

    if (multiplier % 100 == 0) { return; }

    shuffle(enemies);

    double fractionMultiplier = (multiplier % 100) * 0.01;
    uint enemiesNumber        = enemies.Size();
    uint stp                  = uint(round(enemiesNumber * fractionMultiplier));

    if (integerMultiplier >= 1) // add
    {
      for (uint i = 0; i < stp; ++i)
      {
        clone(enemies[i]);
      }
    }
    else // decimate
    {
      for (uint i = stp; i < enemiesNumber; ++i)
      {
        enemies[i].GiveInventory("x5_Killer", 1);
      }
    }
  }

  override void WorldThingSpawned(WorldEvent event)
  {
    let thing = event.thing;

    if (thing != NULL && thing.bMissile && x5_multiplier > 100) { thing.bMThruSpecies = true; }
  }

  // private: ////////////////////////////////////////////////////////////////////

  private
  void clone(Actor original)
  {
    original.bThruSpecies = true;

    let spawned          = Actor.Spawn(original.GetClassName(), original.Pos);
    spawned.bAmbush      = original.bAmbush;
    spawned.bThruSpecies = true;

    // copied from randomspawner.zs
    spawned.SpawnAngle = original.SpawnAngle;
    spawned.Angle      = original.Angle;
    spawned.Pitch      = original.Pitch;
    spawned.Roll       = original.Roll;
    spawned.SpawnPoint = original.SpawnPoint;
    spawned.special    = original.special;
    spawned.args[0]    = original.args[0];
    spawned.args[1]    = original.args[1];
    spawned.args[2]    = original.args[2];
    spawned.args[3]    = original.args[3];
    spawned.args[4]    = original.args[4];
    spawned.special1   = original.special1;
    spawned.special2   = original.special2;
    // MTF_SECRET needs special treatment to avoid incrementing the secret
    // counter twice. It had already been processed for the spawner itself.
    spawned.SpawnFlags = original.SpawnFlags & ~MTF_SECRET;
    spawned.HandleSpawnFlags();

    spawned.SpawnFlags   = original.SpawnFlags;
    // "Transfer" count secret flag to spawned actor
    spawned.bCountSecret = original.SpawnFlags & MTF_SECRET;
    spawned.ChangeTid(original.tid);
    spawned.Vel    = original.Vel;
    // For things such as DamageMaster/DamageChildren, transfer mastery.
    spawned.master = original.master;
    spawned.target = original.target;
    spawned.tracer = original.tracer;
    spawned.CopyFriendliness(original, false);
  }

  // private: ////////////////////////////////////////////////////////////////////

  private
  static bool isCloneable(readonly<Actor> anActor)
  {
    return anActor.bIsMonster && !anActor.bFriendly && anActor.bCountKill;
  }

  private
  static void nudgeCloned()
  {
    Dictionary occupiedPositions = Dictionary.create();

    let iterator = ThinkerIterator.Create("Actor");
    Actor anActor;
    while (anActor = Actor(iterator.Next()))
    {
      anActor.bThruSpecies = true;
      if (!isCloneable(getDefaultByType(anActor.getClass()))) { continue; }

      string positionString
      = string.format("%f-%f-%f", anActor.pos.x, anActor.pos.y, anActor.pos.z);

      // If this position isn't occupied, remember it. If it is, nudge.
      if (occupiedPositions.at(positionString).length() == 0)
      {
        occupiedPositions.insert(positionString, ".");
      }
      else { nudge(anActor); }
    }
  }

  private
  static void nudge(Actor anActor)
  {
    double distance = anActor.radius * 3;
    int startAngle  = Random[x5](-180, 180);
    for (int deltaAngle = 0; deltaAngle <= 360; deltaAngle += 10)
    {
      double angle = Actor.normalize180(startAngle + deltaAngle);
      vector3 move = distance * (cos(angle), sin(angle), 0);

      if (!anActor.checkMove(anActor.pos.xy + move.xy, PCM_NoActors)) { continue; }

      vector3 oldPos = anActor.pos;
      anActor.setOrigin(oldPos + move, true);

      // Free if can move in at least one direction.
      bool isFree = false;
      for (int checkAngle = -180; checkAngle <= 180; checkAngle += 10)
      {
        if (!anActor.checkMove(anActor.pos.xy + (cos(checkAngle), sin(checkAngle)))) { continue; }

        isFree = true;
        break;
      }

      if (isFree) { break; }

      // If stuck, go back, try again.
      anActor.setOrigin(oldPos, true);
    }
  }

  private
  static void shuffle(out Array<Actor> actors)
  {
    // Fisher-Yates shuffle.
    uint numberOfActors = actors.size();
    for (uint i = numberOfActors - 1; i >= 1; --i)
    {
      int j = Random(0, i);

      let temp  = actors[i];
      actors[i] = actors[j];
      actors[j] = temp;
    }
  }

} // class x5_EventHandler
