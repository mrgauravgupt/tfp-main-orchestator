import { prisma } from '../../packages/database/src/client';

async function run() {
  const [users, projects, events, contests, reports, imageModerations, approvedProjects, approvedEvents, approvedContests] = await Promise.all([
    prisma.user.count(),
    prisma.project.count(),
    prisma.event.count(),
    prisma.contest.count(),
    prisma.contentReport.count(),
    prisma.imageModeration.count(),
    prisma.project.count({ where: { status: 'APPROVED' } }),
    prisma.event.count({ where: { status: 'APPROVED' } }),
    prisma.contest.count({ where: { status: 'APPROVED' } }),
  ]);

  console.log(JSON.stringify({ users, projects, events, contests, reports, imageModerations, approvedProjects, approvedEvents, approvedContests }, null, 2));

  const actions = await prisma.imageModeration.groupBy({ by: ['action'], _count: { _all: true } });
  console.log('actions', actions);

  const sample = await prisma.imageModeration.findMany({
    take: 8,
    orderBy: { createdAt: 'desc' },
    select: { id: true, imageKey: true, adult: true, racy: true, violence: true, medical: true, spoof: true, action: true, reason: true, createdAt: true },
  });
  console.log('sample', sample);
}

run().finally(() => prisma.$disconnect());
