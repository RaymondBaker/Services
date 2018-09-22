"use strict";

enum Music_Command {
    NEXT,
    PREV,
    PAUSE_PLAY,
    CHANGE_VOLUME
}

// Get info on load
$(function(){update_info()});

$(document).ready(function() {
    $("#prev_btn").click(function() {
        send_command(Music_Command.PREV);
    });
    $("#play_pause_btn").click(function() {
        send_command(Music_Command.PAUSE_PLAY);
    });
    $("#next_btn").click(function() {
        send_command(Music_Command.NEXT);
    });
    $("#volume_s").change(function() {
        let current_vol = $(this).val() as string;
        send_command(Music_Command.CHANGE_VOLUME, current_vol);
    });

    //Update playing song every 30 secs
    setInterval(function(){
        update_info();
    }, 30000);
});

function update_info()
{
    $.ajax({
        type:"GET",
        url: "/sound_system/info",
        dataType: 'json',
        success: function(info){
            console.log(info);
            if (info.title != 'Unknown') $("#song_name_lbl").text(info.title);
            if (info.artist != 'Unknown') $("#song_artist_lbl").text(info.artist);
            if (info.volume != 'Unknown') $("#volume_s").val(info.volume);
        }
    });
}

function send_command(control: Music_Command, arg?: string) : boolean {
    switch (control)
    {
        case Music_Command.NEXT:
        {
            $.ajax({
                type:"POST",
                url: "/sound_system/sound_control/NEXT"
            });
            break;
        }
        case Music_Command.PREV:
        {
            $.ajax({
                type:"POST",
                url: "/sound_system/sound_control/PREV"
            });
            break;
        }
        case Music_Command.PAUSE_PLAY:
        {
            $.ajax({
                type:"POST",
                url: "/sound_system/sound_control/PAUSE_PLAY"
            });
            break;
        }
        case Music_Command.CHANGE_VOLUME:
        {
            $.ajax({
                type:"POST",
                url: `/sound_system/sound_control/CHANGE_VOLUME/${arg}`
            });
            return true;
            break;
        }
        default:
        {
            return false;
            break;
        }
    }
    update_info();
    return true;
}
