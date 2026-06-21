import { ManualChunk } from './types';

function chunksFor(vehicleId: string, idPrefix: string): ManualChunk[] {
  return [
    {
      id: `${idPrefix}-tire-change`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Changing a Flat Tire',
      pageRef: 47,
      text:
        'If you have a flat tire, park on level ground, engage the parking brake, and turn on your hazard lights. ' +
        'Remove the spare tire, jack, and lug wrench from the trunk well. Loosen the lug nuts a quarter turn before ' +
        'raising the vehicle with the jack. Once raised, remove the lug nuts fully, swap the flat for the spare, ' +
        'then hand-tighten the lug nuts in a star pattern. Lower the vehicle and fully tighten the lug nuts. ' +
        'Drive cautiously to a service station, as the spare is a temporary tire rated for limited speed and distance.',
    },
    {
      id: `${idPrefix}-jack-point`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Jack Point Location',
      pageRef: 49,
      text:
        'The jack points are reinforced sections of the rocker panel directly behind the front wheels and directly ' +
        'in front of the rear wheels, marked with a small notch or arrow on the underbody trim. Always place the ' +
        'jack squarely on the metal jack point, never on the plastic trim, to avoid damaging the vehicle.',
    },
    {
      id: `${idPrefix}-jump-start`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Jump-Starting the Vehicle',
      pageRef: 112,
      text:
        'To jump-start the vehicle, connect the positive (red) jumper cable to the positive terminal of the dead ' +
        'battery, then to the positive terminal of the booster battery. Connect the negative (black) cable to the ' +
        'booster battery negative terminal, then to an unpainted metal ground point on the dead vehicle’s engine ' +
        'block, not the dead battery itself. Start the booster vehicle, wait two minutes, then start the dead vehicle. ' +
        'Remove cables in reverse order.',
    },
    {
      id: `${idPrefix}-warning-check-engine`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Warning Lights: Check Engine Light',
      pageRef: 138,
      text:
        'A steady check engine light indicates a non-urgent emissions or sensor fault; the vehicle is generally ' +
        'safe to drive to a service station for diagnosis. A flashing check engine light indicates a severe misfire ' +
        'that can damage the catalytic converter — reduce speed and seek service immediately, avoiding hard ' +
        'acceleration.',
    },
    {
      id: `${idPrefix}-warning-tpms`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Warning Lights: Tire Pressure (TPMS)',
      pageRef: 140,
      text:
        'The tire pressure warning light (a horseshoe-shaped icon with an exclamation point) means one or more tires ' +
        'is significantly under-inflated. Check all tire pressures as soon as safely possible using the values on ' +
        'the driver-door jamb placard, and inflate to spec. If the light flashes for 60 seconds then stays solid, ' +
        'the TPMS system itself may need service.',
    },
    {
      id: `${idPrefix}-warning-oil-battery`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Warning Lights: Oil Pressure and Battery',
      pageRef: 141,
      text:
        'An oil-can-shaped warning light means oil pressure is critically low — stop driving immediately and shut ' +
        'off the engine to avoid severe engine damage. A battery-shaped warning light indicates the charging system ' +
        'is not charging the battery; you may have limited driving range before the vehicle stalls, so head to the ' +
        'nearest service station.',
    },
    {
      id: `${idPrefix}-check-oil`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Checking Engine Oil Level',
      pageRef: 156,
      text:
        'With the engine off and cool, locate the oil dipstick, pull it out, wipe it clean, reinsert fully, then pull ' +
        'it out again to read the level. Oil should fall between the two marks near the dipstick tip. If below the ' +
        'lower mark, add oil of the recommended viscosity in small increments, rechecking after each addition.',
    },
    {
      id: `${idPrefix}-check-coolant`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Checking Coolant Level',
      pageRef: 158,
      text:
        'Check the coolant reservoir level only when the engine is cool — never open the radiator cap on a hot ' +
        'engine. The coolant level should sit between the MIN and MAX lines on the semi-transparent reservoir tank. ' +
        'Top off with a 50/50 mix of coolant and distilled water if low.',
    },
    {
      id: `${idPrefix}-tire-pressure-spec`,
      vehicleId,
      contentType: 'manual',
      sectionTitle: 'Recommended Tire Pressure Specs',
      pageRef: 162,
      text:
        'Recommended cold tire pressure is 32 PSI front and 32 PSI rear for standard tires, or 35 PSI front and rear ' +
        'when carrying a full load of passengers and cargo. The compact spare tire should be inflated to 60 PSI. ' +
        'Check pressures when tires are cold, before driving more than a mile.',
    },
  ];
}

export const MANUAL_CHUNKS: ManualChunk[] = [
  ...chunksFor('camry-2023', 'camry'),
  ...chunksFor('civic-2022', 'civic'),
];
