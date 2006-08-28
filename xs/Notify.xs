#include "perl_notify.h"

void
perl_notify_notification_add_action(NotifyNotification* notification, gchar* action, gpointer userdata) {
	gperl_callback_invoke((GPerlCallback*)userdata, NULL, notification, action);
}

MODULE = Gtk2::Notify	PACKAGE = Gtk2::Notify	PREFIX = notify_

=for object Gtk2::Notify - Perl interface to libnotify
=cut

=head1 SYNOPSIS

    use Gtk2::Notify -init, "app_name";

    my $notification = Gtk2::Notify->new(
            $summary,
            $message,
            $icon,
            $attach_widget
    );
    $notification->show;

=head1 INITIALISATION

    use Gtk2::Notify qw/-init app_name/;

=over

=item -init

Importing Gtk2::Notify with the -init option requires one additional argument: the application name to use. This is equivalent to Gtk2::Notify->init($app_name).

=back

=cut

gboolean
notify_init(class, app_name)
		const char* app_name
	C_ARGS: app_name

void
notify_uninit(class)
	C_ARGS: /* void */

gboolean
notify_is_initted(class)
	C_ARGS: /* void */

const gchar*
notify_get_app_name(class)
	C_ARGS: /* void */

void
notify_get_server_caps(class)
	PREINIT:
		GList *list, *tmp;
	PPCODE:
		list = notify_get_server_caps();
		for (tmp = list; tmp != NULL; tmp = tmp->next) {
			XPUSHs(sv_2mortal( newSVGChar(tmp->data) ));
		}
		g_list_free(list);

void
notify_get_server_info(class)
	PREINIT:
		gboolean success;
		char* name;
		char* vendor;
		char* version;
		char* spec_version;
	PPCODE:
		success = notify_get_server_info(&name, &vendor, &version, &spec_version);

		if (!success) {
			XSRETURN_EMPTY;
		}

		EXTEND(SP, 4);
		mPUSHp(name, strlen(name));
		mPUSHp(vendor, strlen(vendor));
		mPUSHp(version, strlen(version));
		mPUSHp(spec_version, strlen(spec_version));

MODULE = Gtk2::Notify	PACKAGE = Gtk2::Notify	PREFIX = notify_notification_

NotifyNotification*
notify_notification_new(class, summary, message=NULL, icon=NULL, attach=NULL)
		const gchar* summary
		const gchar* message
		const gchar* icon
		GtkWidget_ornull* attach
	C_ARGS: summary, message, icon, attach

gboolean
notify_notification_update(notification, summary, message=NULL, icon=NULL)
		NotifyNotification* notification
		const gchar* summary
		const gchar* message
		const gchar* icon

void
notify_notification_attach_to_widget(notification, attach)
		NotifyNotification* notification
		GtkWidget* attach

void
notify_notification_show(notification)
		NotifyNotification* notification
	PREINIT:
		GError* error = NULL;
	CODE:
		if (!notify_notification_show(notification, &error))
			gperl_croak_gerror(NULL, error);

void
notify_notification_set_timeout(notification, timeout)
		NotifyNotification* notification
		gint timeout

void
notify_notification_set_category(notification, category)
		NotifyNotification* notification
		const char* category

void
notify_notification_set_urgency(notification, urgency)
		NotifyNotification* notification
		NotifyUrgency urgency

void
notify_notification_set_icon_from_pixbuf(notification, icon)
		NotifyNotification* notification
		GdkPixbuf* icon

=for TODO
A generic set_hint()
=cut

void
notify_notification_set_hint_int32(notification, key, value)
		NotifyNotification* notification
		const gchar* key
		gint value

void
notify_notification_set_hint_double(notification, key, value)
		NotifyNotification* notification
		const gchar* key
		gdouble value

void
notify_notification_set_hint_string(notification, key, value)
		NotifyNotification* notification
		const gchar* key
		const gchar* value

void
notify_notification_set_hint_byte(notification, key, value)
		NotifyNotification* notification
		const gchar* key
		guchar value

void
notify_notification_set_hint_byte_array(notification, key, value)
		NotifyNotification* notification
		const gchar* key
		const guchar* value
	C_ARGS: notification, key, value, sv_len(ST(3))

void
notify_notification_clear_hints(notification)
		NotifyNotification* notification

void
notify_notification_add_action(notification, action, label, callback, userdata=NULL)
		NotifyNotification* notification
		const char* action
		const char* label
		SV* callback
		SV* userdata
	PREINIT:
		GType param_types[2];
		GPerlCallback* cb;
	CODE:
		param_types[0] = NOTIFY_TYPE_NOTIFICATION;
		param_types[1] = G_TYPE_STRING;

		cb = gperl_callback_new(callback, userdata, 2, param_types, G_TYPE_NONE);
		notify_notification_add_action(notification, action, label, perl_notify_notification_add_action, cb, (GFreeFunc)gperl_callback_destroy);

void
notify_notification_clear_actions(notification)
		NotifyNotification* notification

void
notify_notification_close(notification)
		NotifyNotification* notification
	PREINIT:
		GError* error = NULL;
	CODE:
		if (!notify_notification_close(notification, &error))
			gperl_croak_gerror(NULL, error);

BOOT:
#include "register.xsh"
#include "boot.xsh"

=for position post_enums

=head1 BUGS

Please report any bugs or feature requests to
C<bug-gtk2-notify at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Gtk2-Notify>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Gtk2::Notify

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Gtk2-Notify>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Gtk2-Notify>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Gtk2-Notify>

=item * Search CPAN

L<http://search.cpan.org/dist/Gtk2-Notify>

=back

=cut

