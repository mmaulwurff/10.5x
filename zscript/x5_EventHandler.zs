// SPDX-FileCopyrightText: 2019-2020, 2022 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class x5_EventHandler : EventHandler
{

  // The multiplier must work immediately, because RandomSpawners are still
  // RandomSpawners, so they will transform to randomized enemies.
  //
  // The divider, on the contrary, must work when RandomSpawners and other
  // spawners are already transformed to enemies.
  enum ActTimes
  {
    BEFORE_RANDOMIZED = 0,
    AFTER_RANDOMIZED  = 4,
    TIME_TO_PRINT     = 5
  };

  override void WorldLoaded(WorldEvent event)
  {
    mEnemyTypes = collectEnemyTypes();
  }

  override void UiTick()
  {
    if (mFirstTickDone) { return; }
    mFirstTickDone = true;

    if (x5_multiplier == 0)
    {
      if (netgame)
      {
        Console.Printf("10.5x: Enemy multipliers by type aren't available in multiplayer.");
      }
      else { openTypeMultipliersMenu(); }
    }

  }

  private ui
  void openTypeMultipliersMenu()
  {
    let descriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("x5_TypeMultipliers"));
    descriptor.mItems.clear();

    for (let i = DictionaryIterator.Create(mEnemyTypes); i.Next();)
    {
      Class<Actor> enemyClass = i.Key();
      let defaultEnemy = getDefaultByType(enemyClass);
      let slider = new("OptionMenuItemX5TypeSlider");
      slider.Init(defaultEnemy.getTag());
      descriptor.mItems.push(slider);
    }

    Menu.SetMenu("x5_TypeMultipliers");
  }

  private ui bool mFirstTickDone;
  private Dictionary mEnemyTypes;

  override void WorldTick()
  {
    int multiplier = x5_multiplier;
    int timeToAct  = (multiplier >= 100) ? BEFORE_RANDOMIZED : AFTER_RANDOMIZED;

    if (level.maptime == AFTER_RANDOMIZED + 1 && multiplier > 100) { nudgeCloned(); }

    if (level.maptime == TIME_TO_PRINT)
    {
      x5_Density.printMonsterDensity();
      return;
    }
    else if (level.maptime != timeToAct) { return; }

    if (multiplier == 100) { return; }

    Array<Actor> monsters;

    let iterator = ThinkerIterator.Create("Actor");
    Actor anActor;
    while (anActor = Actor(iterator.Next()))
    {
      let defaultReplacee = getDefaultByType(Actor.getReplacee(anActor.getClassName()));
      if (isCloneable(defaultReplacee)) { monsters.push(anActor); }
    }

    Array<String> classes;
    int integerMultiplier = multiplier / 100;
    int nCopies           = integerMultiplier - 1;
    foreach (monster : monsters)
    {
      String className = monster.GetClassName();
      if (classes.Find(className) == classes.size()) { classes.Push(className); }

      for (int c = 0; c < nCopies; ++c)
      {
        clone(monster);
      }
    }

    double fractionMultiplier = (multiplier % 100) * 0.01;

    foreach (className : classes)
    {
      Array<Actor> monstersByClass;
      foreach (monster : monsters)
      {
        if (monster.GetClassName() == className) { monstersByClass.Push(monster); }
      }

      uint nMonstersInClass = monstersByClass.size();
      Array<Actor> shuffled;
      shuffled.Resize(nMonstersInClass);
      for (uint i = 0; i < nMonstersInClass; ++i)
      {
        int r = Random(0, nMonstersInClass - 1);
        for (uint j = 0; j < nMonstersInClass; ++j)
        {
          uint index = (r + j) % nMonstersInClass;
          if (shuffled[index] == NULL)
          {
            shuffled[index] = monstersByClass[i];
            break;
          }
        }
      }

      uint stp = uint(round(nMonstersInClass * fractionMultiplier));

      if (integerMultiplier >= 1) // add
      {
        for (uint i = 0; i < stp; ++i)
        {
          clone(shuffled[i]);
        }
      }
      else // decimate
      {
        for (uint i = stp; i < nMonstersInClass; ++i)
        {
          shuffled[i].GiveInventory("x5_Killer", 1);
        }
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
    int startAngle  = random(-180, 180);
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
  static Dictionary collectEnemyTypes()
  {
    let result = Dictionary.Create();
    Actor anActor;
    for (let i = ThinkerIterator.Create("Actor"); anActor = Actor(i.Next());)
    {
      let replaceeType    = Actor.getReplacee(anActor.getClassName());
      let defaultReplacee = getDefaultByType(replaceeType);

      if (isCloneable(defaultReplacee)) { result.insert(replaceeType.getClassName(), ""); }
    }

    return result;
  }

} // class x5_EventHandler
