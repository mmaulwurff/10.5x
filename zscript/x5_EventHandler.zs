/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019
 *
 * This file is a part of Typist.pk3.
 *
 * Typist.pk3 is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Typist.pk3 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Typist.pk3.  If not, see <https://www.gnu.org/licenses/>.
 */

// It should be illegal to write code like this.
class x5_EventHandler : EventHandler
{
  Array<Actor> monsters;
  Array<String> classes;

  override void WorldTick()
  {
    if (level.time != 0) return;

    int multiplier = Cvar.GetCvar("x5_multiplier").GetInt();
    if (multiplier == 100) return;

    let iterator = ThinkerIterator.Create("Actor");
    Actor monster;
    while (monster = Actor(iterator.Next()))
    {
      if (monster.bIsMonster) monsters.Push(monster);
    }

    int integerMultiplier = multiplier / 100;
    int nCopies = integerMultiplier - 1;
    for (uint i = 0; i < monsters.size(); ++i)
    {
      let monster = monsters[i];
      monster.bThruSpecies = true;
      String className = monster.GetClassName();
      if (classes.Find(className) == classes.size())
      {
        classes.Push(className);
      }

      for (int c = 0; c < nCopies; ++c)
      {
        let spawned = Actor.Spawn(className, monster.Pos);
        spawned.bAmbush = monster.bAmbush;
        spawned.angle = monster.angle;
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

      Array<Actor> shuffled;
      shuffled.Clear();
      shuffled.Resize(monstersByClass.size());
      for (uint i = 0; i < monstersByClass.size(); ++i)
      {
        int r = Random(0, monstersByClass.size() - 1);
        for (uint j = 0; j < monstersByClass.size(); ++j)
        {
          uint index = (r + j) % monstersByClass.size();
          if (shuffled[index] == NULL)
          {
            shuffled[index] = monstersByClass[i];
            break;
          }
        }
      }

      uint stp = round(monstersByClass.size() * fractionMultiplier);

      if (integerMultiplier > 1) // add
      {
        for (uint i = 0; i < stp; ++i)
        {
          let original = shuffled[i];
          let spawned = Actor.Spawn(original.GetClassName(), original.Pos);
          spawned.bAmbush = original.bAmbush;
          spawned.angle = original.angle;
        }
      }
      else // decimate
      {
        for (uint i = stp; i < monstersByClass.size(); ++i)
        {
          shuffled[i].A_Die();
        }
      }
    }
  }
}
