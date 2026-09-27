# Shallow Knight

*An Adventure of Questionable Depth*

**Planned genre:** 2D action platformer.

An inexperienced knight ventures into a forgotten underground kingdom, determined
to become a legendary hero. Unfortunately, he is afraid of the dark. Armed with a
wooden stick and unreasonable confidence, he explores only the shallowest caves,
mistaking ordinary pebbles for priceless treasures and minor accomplishments for
epic victories. He believes he has conquered the depths, but the actual kingdom
begins another ten meters below.

## Week 2: Core mechanic

Jump between platforms and hit Cave Crawlers with a wooden stick.

Open `project.godot` in Godot 4 Standard and click **Run Project**. Move with
**A/D** or the **arrow keys**, jump with **W**, attack with **left mouse click**, and reset
the current level with **R**. Three markers above the knight show health; losing
all health restarts the room. Crawlers take two hits. Landing dust adds feedback.

## Week 3: Two levels

**The Shallows** introduces gaps, Cave Crawlers, and spikes separately.
**Slightly Deeper** combines them with higher ledges and longer jumps. Both use
editable TileMapLayer terrain. Reach the pale-blue doorway to advance; finish
the second level and press **R** to play again.

Collect three optional Legendary Pebbles per level. The total carries between
levels, and collected pebbles stay collected after a death or restart.

**Inclusive design:** Clear terrain edges, pointed hazards, and distinct collectible
shapes communicate meaning beyond color; the humor targets the fictional knight's
overconfidence rather than real cultures or identities.

## Week 4: Animation, particles, and AI art

The knight now uses original SVG sprite parts animated with **AnimationPlayer**:
idle breathing, walking legs/cape, a stick swing, and an airborne pose. The player
script chooses animations from movement and attack state. The collision shapes
remain separate from the animated artwork. Landing dust now uses soft particles
that fade out, stay behind as the player moves, and respond to landing speed.

**AI tool:** OpenAI's built-in `image_gen` tool in Codex. The initial cave image was
generated, then edited with the same tool to soften ruins, suppress reflections,
and reduce foreground distractions. A second edit produced a darker cave with
taller rocks and sparse plants for Slightly Deeper. Both final PNGs are imported
into Godot as decorative parallax backgrounds, scaled to 1280 × 720 and tinted
with RGB multipliers (0.65, 0.70, 0.78) for gameplay contrast. They provide no
collision. The unedited source is retained for comparison.

The exact generation/edit prompts and file mapping are recorded in
[the asset notes](assets/backgrounds/ART_NOTES.md).
