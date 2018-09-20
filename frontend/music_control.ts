"use strict";

enum Music_Command {
    NEXT,
    PREV, 
    PAUSE_PLAY,
}

// Get info on load
$(function(){update_song_info()});

$(document).ready(function() {
    $("#prev_btn").click(function() {
        change_song(Music_Command.PREV);
    });
    $("#play_pause_btn").click(function() {
        change_song(Music_Command.PAUSE_PLAY);
    });
    $("#next_btn").click(function() {
        change_song(Music_Command.NEXT);
    });

    //Update playing song every 30 secs
    setInterval(function(){
        update_song_info();
    }, 30000);
});

function update_song_info()
{
    $.ajax({
        type:"GET",
        url: "/sound_system/sound_control_current_playing",
        dataType: 'json',
        success: function(info){
            $("#song_name_lbl").text(`${info.title}`);
            $("#song_artist_lbl").text(`${info.artist}`);
        }
    });
}

function change_song(control: Music_Command) : boolean {
    var next_song = "";
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
        default: 
        {
            return false;
            break;
        }
    }
    update_song_info();
    return true;
}
