# Cave artwork provenance

Created for Week 4 using OpenAI's built-in `image_gen` generation/edit tool in Codex. No external game's artwork was supplied as a reference.

## Files and editing sequence

1. `source/shallows-generated.png`: unedited generated image, retained as evidence; `.gdignore` keeps the source folder out of Godot imports.
2. `shallows.png`: edited from the source to soften distant structures, remove reflective water highlights, and reduce foreground distractions.
3. `slightly-deeper.png`: edited from the cleaned Shallows image into a darker cave with taller rock formations and sparse plants.

Godot displays the final PNGs on Sprite2D nodes inside Parallax2D, with 1280 × 720 display dimensions, scroll scale (0.12, 0.05), and color multipliers (0.65, 0.70, 0.78). This is non-destructive in-engine scaling/color correction; the PNG pixel dimensions are unchanged. Platforms and hazards remain separate, collidable game objects. The character's SVG parts are original code-authored artwork, not generated images.

## Generation prompt

Use case: stylized-concept. Create an original 2D side-scrolling game decorative cave background for Shallow Knight, a small humorous underground adventure. Wide landscape 16:9. Hand-painted storybook dark fantasy, simple broad shapes, layered distant weathered stone pillars and modest ruined arches, sparse tiny glowing blue mushrooms, misty desaturated blue-gray atmosphere. Relatively bright shallow cavern but overall low contrast and dark enough for pale characters and readable text in front. Flat side view, no perspective floor grid. Upper third mostly quiet dark blue negative space. No characters, weapons, text, logos, UI, collectibles, spikes, doorways, or playable foreground platforms. Entire image is distant decorative scenery, no sharp ground edges that could be mistaken for collision. Original design, do not reproduce existing game locations or artwork.

## Shallows cleanup prompt

Use case: lighting-weather / precise-object-edit. Edit this generated cave background for integration behind a 2D platformer. Preserve the original wide composition, distant arches, stone pillars, mushrooms and blue-gray palette. Reduce contrast and brightness in the lower two thirds by about 35%, soften the hard edges of ruins into distant atmospheric haze, remove the near black foreground boulders and replace them with soft mist. Remove reflective water highlights so they cannot read as walkable terrain. Keep upper third quiet dark blue for text. No new subjects, no characters, no text, no platforms or UI. This is the relatively brighter Shallows background, still subdued behind gameplay.

## Slightly Deeper edit prompt

Use case: lighting-weather and precise-object-edit. Using this original generated and cleaned cave background as the style reference and edit target, create the Slightly Deeper variant for the same 2D game. Preserve wide 16:9, painterly blue-gray style, quiet upper third, and low-contrast distant background role. Change the central architecture into taller irregular natural rock formations, reduce ruined arches, add sparse mysterious thin cave plants and faint blue bioluminescence, deepen shadows substantially and shift palette toward midnight navy. Keep distant shapes soft, no bright reflections or foreground floor. No characters, weapons, text, UI, playable platforms, spikes, collectibles, or exit doors. This is visibly a different, darker cave in the same original world.
