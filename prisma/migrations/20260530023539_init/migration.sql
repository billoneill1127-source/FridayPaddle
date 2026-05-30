-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('man', 'woman');

-- CreateEnum
CREATE TYPE "ReachMode" AS ENUM ('subscription', 'broadcast');

-- CreateEnum
CREATE TYPE "GenderCategory" AS ENUM ('men', 'women', 'mixed');

-- CreateEnum
CREATE TYPE "OccurrenceState" AS ENUM ('scheduled', 'open', 'closed', 'confirmed', 'cancelled');

-- CreateEnum
CREATE TYPE "SignupState" AS ENUM ('active', 'cancelled');

-- CreateEnum
CREATE TYPE "OfferState" AS ENUM ('pending', 'accepted', 'declined', 'expired');

-- CreateTable
CREATE TABLE "players" (
    "id" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "gender" "Gender" NOT NULL,
    "level" INTEGER NOT NULL,
    "token" TEXT NOT NULL,
    "isSuperAdmin" BOOLEAN NOT NULL DEFAULT false,
    "commsPaused" BOOLEAN NOT NULL DEFAULT false,
    "pauseUntil" TIMESTAMP(3),
    "verifiedAt" TIMESTAMP(3),
    "consentedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "players_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "events" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdById" TEXT NOT NULL,
    "reachMode" "ReachMode" NOT NULL,
    "genderCategory" "GenderCategory" NOT NULL,
    "levelMin" INTEGER,
    "levelMax" INTEGER,
    "capacity" INTEGER NOT NULL,
    "requiresCompleteGroups" BOOLEAN NOT NULL DEFAULT true,
    "minimumToHold" INTEGER NOT NULL DEFAULT 0,
    "waitlistEnabled" BOOLEAN NOT NULL DEFAULT true,
    "recurrenceRule" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "occurrences" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "eventAt" TIMESTAMP(3) NOT NULL,
    "signupsOpenAt" TIMESTAMP(3) NOT NULL,
    "cancelDeadline" TIMESTAMP(3) NOT NULL,
    "state" "OccurrenceState" NOT NULL DEFAULT 'scheduled',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "occurrences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "signups" (
    "id" TEXT NOT NULL,
    "occurrenceId" TEXT NOT NULL,
    "playerId" TEXT,
    "placeholderName" TEXT,
    "sequence" INTEGER NOT NULL,
    "state" "SignupState" NOT NULL DEFAULT 'active',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "signups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscriptions" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "waitlist_offers" (
    "id" TEXT NOT NULL,
    "occurrenceId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "state" "OfferState" NOT NULL DEFAULT 'pending',
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "waitlist_offers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reminder_rules" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "offset" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reminder_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "levels" (
    "value" INTEGER NOT NULL,

    CONSTRAINT "levels_pkey" PRIMARY KEY ("value")
);

-- CreateIndex
CREATE UNIQUE INDEX "players_phone_key" ON "players"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "players_token_key" ON "players"("token");

-- CreateIndex
CREATE INDEX "occurrences_eventId_idx" ON "occurrences"("eventId");

-- CreateIndex
CREATE INDEX "signups_occurrenceId_idx" ON "signups"("occurrenceId");

-- CreateIndex
CREATE INDEX "signups_playerId_idx" ON "signups"("playerId");

-- CreateIndex
CREATE UNIQUE INDEX "signups_occurrenceId_sequence_key" ON "signups"("occurrenceId", "sequence");

-- CreateIndex
CREATE UNIQUE INDEX "subscriptions_playerId_eventId_key" ON "subscriptions"("playerId", "eventId");

-- CreateIndex
CREATE INDEX "waitlist_offers_occurrenceId_idx" ON "waitlist_offers"("occurrenceId");

-- CreateIndex
CREATE INDEX "waitlist_offers_state_idx" ON "waitlist_offers"("state");

-- CreateIndex
CREATE INDEX "reminder_rules_eventId_idx" ON "reminder_rules"("eventId");

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "players"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "occurrences" ADD CONSTRAINT "occurrences_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "signups" ADD CONSTRAINT "signups_occurrenceId_fkey" FOREIGN KEY ("occurrenceId") REFERENCES "occurrences"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "signups" ADD CONSTRAINT "signups_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "players"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "players"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "waitlist_offers" ADD CONSTRAINT "waitlist_offers_occurrenceId_fkey" FOREIGN KEY ("occurrenceId") REFERENCES "occurrences"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "waitlist_offers" ADD CONSTRAINT "waitlist_offers_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "players"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reminder_rules" ADD CONSTRAINT "reminder_rules_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

INSERT INTO "levels" ("value") VALUES (7), (9), (11), (13), (15), (17), (19), (21), (23), (25), (27), (29), (31);
