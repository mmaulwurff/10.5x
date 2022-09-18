Submitted by Accensus:

> Although it's quite specific, would it be possible to adjust the count of vanilla monsters (or those inheriting from vanilla monsters) individually?  
   Like, reducing only the number of zombiemen and shotgunners while keeping the number of everything else intact.

---

### **[ghost](https://github.com/ghost)** commented [on Dec 26, 2019](https://github.com/mmaulwurff/10.5x/issues/4#issuecomment-568933134)

I'd like to mention that this would not really work for totally custom monsters. The only way to have full compatibility is to leave it in the hands of the users to make their own compatibility patches via an external lump, then generate a slider for each class in it.

OR

Create a slider for each class in the AllActorClasses array that also has the ISMONSTER flag.

There may also be a 3rd option that I'm not aware of right now.