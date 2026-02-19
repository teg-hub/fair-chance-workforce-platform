import { randomUUID } from 'crypto';
import { NextRequest, NextResponse } from 'next/server';
import { getAuthContext, getSupabaseServerClient } from '@/lib/supabase';

const NOTE_TYPES = new Set(['intake', 'coaching_session', 'resource_referral', 'crisis', 'follow_up']);
const MEETING_LOCATIONS = new Set(['office', 'garage', 'newberry', 'community', 'phone', 'video', 'text', 'email']);

function isIsoDate(value: string) {
  return /^\d{4}-\d{2}-\d{2}$/.test(value);
}

function isIsoDateTime(value: string) {
  return !Number.isNaN(Date.parse(value));
}

export async function POST(req: NextRequest) {
  try {
    const auth = getAuthContext(req.headers.get('authorization'));
    const body = await req.json();

    const required = ['employee_id', 'case_id', 'note_type', 'note_start_date', 'interaction_at', 'meeting_location', 'areas_of_need_codes'];
    for (const key of required) {
      if (!(key in body)) return NextResponse.json({ detail: 'Missing required fields' }, { status: 400 });
    }

    if (!NOTE_TYPES.has(body.note_type)) return NextResponse.json({ detail: 'Invalid note_type' }, { status: 400 });
    if (!isIsoDate(body.note_start_date)) return NextResponse.json({ detail: 'note_start_date must be ISO date (YYYY-MM-DD)' }, { status: 400 });
    if (!isIsoDateTime(body.interaction_at)) return NextResponse.json({ detail: 'interaction_at must be ISO datetime' }, { status: 400 });
    if (!MEETING_LOCATIONS.has(body.meeting_location)) return NextResponse.json({ detail: 'Invalid meeting_location' }, { status: 400 });

    const supabase = getSupabaseServerClient();
    const { data: caseRow } = await supabase.from('cases').select('id, tenant_id, employee_id').eq('id', body.case_id).maybeSingle();

    if (!caseRow) return NextResponse.json({ detail: 'Case not found' }, { status: 404 });
    if (caseRow.tenant_id !== auth.tenantId) return NextResponse.json({ detail: 'Cross-tenant access denied' }, { status: 403 });
    if (caseRow.employee_id !== body.employee_id) return NextResponse.json({ detail: 'Employee/case mismatch' }, { status: 400 });

    const noteId = randomUUID();
    const { error } = await supabase.from('progress_notes').insert({
      id: noteId,
      tenant_id: auth.tenantId,
      employee_id: body.employee_id,
      case_id: body.case_id,
      coordinator_id: auth.userId,
      note_type: body.note_type,
      note_start_date: body.note_start_date,
      interaction_at: body.interaction_at,
      meeting_location: body.meeting_location,
      areas_of_need_codes: body.areas_of_need_codes,
      summary_of_meeting: body.summary_of_meeting ?? null,
      status: body.status ?? 'draft',
      created_at: new Date().toISOString(),
    });

    if (error) return NextResponse.json({ detail: error.message }, { status: 500 });
    return NextResponse.json({ id: noteId, status: body.status ?? 'draft' });
  } catch {
    return NextResponse.json({ detail: 'Invalid token or JSON body' }, { status: 401 });
  }
}
