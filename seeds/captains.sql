UPDATE Teams
SET CaptainId = (FLOOR(RANDOM() * 15)::INT + 1) + 15 * (TeamId - 1);