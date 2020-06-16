/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019-2020
 *
 * This file is a part of 10.5x.
 *
 * 10.5x is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * 10.5x is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * 10.5x.  If not, see <https://www.gnu.org/licenses/>.
 */

// It should be illegal to write code like this.
class x5_EventHandler : EventHandler
{

// public: // EventHandler /////////////////////////////////////////////////////

  override
  void WorldTick()
  {
    int multiplier = x5_multiplier;

    // miltiplier must work immediately, because RandomSpawners are still
    // RandomSpawners, so they will transform to randomized enemies.
    //
    // divider, on the contrary, must work when RandomSpawners are already
    // transformed to enemies.
    int timeToAct  = (multiplier >= 100) ? 0 : 1;

    if (level.time == 3)
    {
      x5_Density.printMonsterDensity();
      return;
    }
    else if (level.time != timeToAct)
    {
      return;
    }

    if (multiplier == 100)
    {
      return;
    }

    let iterator = ThinkerIterator.Create("Actor");
    Actor monster;
    while (monster = Actor(iterator.Next()))
    {
      if (GetDefaultByType(Actor.GetReplacee(monster.GetClassName())).bIsMonster)
      {
        monsters.Push(monster);
      }
    }

    int integerMultiplier = multiplier / 100;
    int nCopies = integerMultiplier - 1;
    for (uint i = 0; i < monsters.size(); ++i)
    {
      let monster = monsters[i];
      String className = monster.GetClassName();
      if (classes.Find(className) == classes.size())
      {
        classes.Push(className);
      }

      for (int c = 0; c < nCopies; ++c)
      {
        clone(monster);
      }
    }

    double fractionMultiplier = (multiplier % 100) * 0.01;

    for (uint i = 0; i < classes.size(); ++i)
    {
      String className = classes[i];
      Array<Actor> monstersByClass;
      monstersByClass.Clear(); // array is not cleared on next iteration.
      for (uint i = 0; i < monsters.size(); ++i)
      {
        if (monsters[i].GetClassName() == className)
        {
          monstersByClass.Push(monsters[i]);
        }
      }

      uint nMonstersInClass = monstersByClass.size();
      Array<Actor> shuffled;
      shuffled.Clear();
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

  override
  void WorldThingSpawned(WorldEvent event)
  {
    let thing = event.thing;
    if (thing == NULL)
    {
      return;
    }

    if (thing.bMissile && x5_multiplier > 100)
    {
      thing.bMThruSpecies = true;
    }
  }

// private: ////////////////////////////////////////////////////////////////////

  private
  void clone(Actor original)
  {
    original.bThruSpecies = true;

    let spawned = Actor.Spawn(original.GetClassName(), original.Pos);
    spawned.bAmbush = original.bAmbush;
    spawned.bThruSpecies = true;

    // copied from randomspawner.zs
    spawned.SpawnAngle   = original.SpawnAngle;
    spawned.Angle        = original.Angle;
    spawned.Pitch        = original.Pitch;
    spawned.Roll         = original.Roll;
    spawned.SpawnPoint   = original.SpawnPoint;
    spawned.special      = original.special;
    spawned.args[0]      = original.args[0];
    spawned.args[1]      = original.args[1];
    spawned.args[2]      = original.args[2];
    spawned.args[3]      = original.args[3];
    spawned.args[4]      = original.args[4];
    spawned.special1     = original.special1;
    spawned.special2     = original.special2;
    // MTF_SECRET needs special treatment to avoid incrementing the secret
    // counter twice. It haoriginal.d already been processed for the spawner itself.
    spawned.SpawnFlags   = original.SpawnFlags & ~MTF_SECRET;
    spawned.HandleSpawnFlags();

    spawned.SpawnFlags   = original.SpawnFlags;
    // "Transfer" count secret flag to spawned actor
    spawned.bCountSecret = original.SpawnFlags & MTF_SECRET;
    spawned.ChangeTid(original.tid);
    spawned.Vel          = original.Vel;
    // For things such as DamageMaster/DamageChildren, transfer mastery.
    spawned.master       = original.master;
    spawned.target       = original.target;
    spawned.tracer       = original.tracer;
    spawned.CopyFriendliness(original, false);

    if (!(spawned is "RandomSpawner"))
    {
      int thrust = x5_thrust * 50 / spawned.mass;
      spawned.Thrust(thrust, random(0, 360));
      spawned.vel.z = thrust;
    }
  }

// private: ////////////////////////////////////////////////////////////////////

  private Array<Actor> monsters;
  private Array<String> classes;

} // class x5_EventHandler
