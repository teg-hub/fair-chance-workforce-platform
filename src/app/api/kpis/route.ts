import { NextRequest, NextResponse } from 'next/server';
import { getAuthContext, getSupabaseServerClient } from '@/lib/supabase';

export async function GET(req: NextRequest) {
  try {
    const auth = getAuthContext(req.headers.get('authorization'));
    const supabase = getSupabaseServerClient();

    const [{ count: intakeCount }, { count: caseOpenCount }, { count: engagementCount }, { count: assignedCount }, { count: respondedCount }, { count: notesTotal }, { count: notesFinal }] =
      await Promise.all([
        supabase.from('referrals').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId),
        supabase.from('cases').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId).in('case_status', ['open', 'active_support']),
        supabase.from('progress_notes').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId),
        supabase.from('referrals').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId).not('assigned_coordinator_id', 'is', null),
        supabase.from('referrals').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId).not('assigned_coordinator_id', 'is', null).not('first_response_at', 'is', null),
        supabase.from('progress_notes').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId),
        supabase.from('progress_notes').select('*', { count: 'exact', head: true }).eq('tenant_id', auth.tenantId).eq('status', 'final'),
      ]);

    const referralResponseRate = assignedCount ? Number(((respondedCount ?? 0) / assignedCount).toFixed(4)) : 0;
    const progressNoteSubmissionRate = notesTotal ? Number(((notesFinal ?? 0) / notesTotal).toFixed(4)) : 0;

    return NextResponse.json({
      intake_volume: intakeCount ?? 0,
      case_open_count: caseOpenCount ?? 0,
      employee_engagement_count: engagementCount ?? 0,
      referral_response_rate: referralResponseRate,
      progress_note_submission_rate: progressNoteSubmissionRate,
    });
  } catch {
    return NextResponse.json({ detail: 'Invalid token' }, { status: 401 });
  }
}
