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

class x5_Density play
{

// public: /////////////////////////////////////////////////////////////////////

  static
  void printMonsterDensity()
  {
    let message = "Estimated enemy density: %.3f, health: %.3f.";

    uint nMonsters = 0;
    uint nHealth   = 0;
    int minX;
    int minY;
    int maxX;
    int maxY;
    bool isFirst = true;
    let i = ThinkerIterator.Create("Actor");
    Actor mo;
    while (mo = Actor(i.Next()))
    {
      bool isMonster = mo.bIsMonster;
      if (!(isMonster || mo is "Inventory")) { continue; }

      if (isMonster)
      {
        ++nMonsters;
        nHealth += mo.Health;
      }

      if (isFirst)
      {
        minX = int(mo.pos.x);
        minY = int(mo.pos.y);
        maxX = int(mo.pos.x);
        maxY = int(mo.pos.y);
        continue;
      }

      if      (mo.pos.x < minX) { minX = int(mo.pos.x); }
      else if (mo.pos.x > maxX) { maxX = int(mo.pos.x); }

      if      (mo.pos.y < minY) { minY = int(mo.pos.y); }
      else if (mo.pos.y > maxY) { maxY = int(mo.pos.y); }
    }

    if (nMonsters == 0)
    {
      Console.Printf(message, 0, 0);
      return;
    }

    int radius = int(players[consolePlayer].mo.radius);
    if (maxY - minY < radius) { maxY = minY + radius; }
    if (maxX - minX < radius) { maxX = minX + radius; }

    int area = (maxX - minX) * (maxY - minY);

    double density       = double(nMonsters) / area / 0.113281; // Doom E1M1 UV
    double healthDensity = double(nHealth)   / area / 3.515625; // Doom E1M1 UV
    Console.Printf(message, density, healthDensity);
  }

} // class x5_Density
