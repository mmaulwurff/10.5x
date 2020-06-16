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

class x5_Killer : Inventory
{

// public: /////////////////////////////////////////////////////////////////////

  override void Tick()
  {
    Super.Tick();

    if (Owner != null)
    {
      state spawnState = Owner.FindState("Spawn");
      state idleState = Owner.FindState("Idle");
      if (!Owner.InStateSequence(Owner.CurState, spawnState)
          && !Owner.InStateSequence(Owner.CurState, idleState))
      {
        Owner.A_Die();
        Owner.bCorpse = x5_raise_divided;
        Destroy();
      }
    }
  }

} // class x5_Killer
