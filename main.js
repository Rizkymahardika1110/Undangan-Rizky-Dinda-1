document.addEventListener("DOMContentLoaded", function(){

// ================== KONFIRMASI KEHADIRAN ==================
let confirmedGuests = JSON.parse(localStorage.getItem('weddingConfirmedGuests') || '[]');

function saveConfirmedGuests(){
    localStorage.setItem('weddingConfirmedGuests', JSON.stringify(confirmedGuests));
    renderConfirmedList();
}

function renderConfirmedList(){

    const container = document.getElementById('confirmedList');
    if(!container) return;

    if(confirmedGuests.length === 0){
        container.innerHTML = '<div class="empty-confirmed">Belum ada konfirmasi.</div>';
        return;
    }

    let html="";

    confirmedGuests.forEach(guest=>{

        const statusClass = guest.status === "Hadir" ? "status-hadir" : "status-tidak";
        const jumlahText = guest.jumlah ? `👥 ${guest.jumlah} orang` : "";

        html+=`
        <div class="confirmed-item">
        <span class="confirmed-name">${escapeHtml(guest.name)}</span>
        <span class="confirmed-status ${statusClass}">${guest.status}</span>
        <span class="confirmed-jumlah">${jumlahText}</span>
        </div>
        `;

    });

    container.innerHTML = html;
}

function addConfirmation(name,status,jumlah){

const existing = confirmedGuests.findIndex(g=>g.name.toLowerCase()===name.toLowerCase());

if(existing !== -1){
confirmedGuests[existing] = {name,status,jumlah}
}else{
confirmedGuests.push({name,status,jumlah})
}

saveConfirmedGuests();

}


// ================== KOMENTAR DATABASE ==================
function loadComments(){

fetch("get_comments.php")
.then(res=>res.json())
.then(data=>{

const container=document.getElementById("comments-list");
if(!container) return;

let html="";

data.forEach(comment=>{

html+=`
<tr>
<td>${escapeHtml(comment.name)}</td>
<td>${escapeHtml(comment.message)}</td>
<td>${comment.created_at}</td>
</tr>
`;

});

container.innerHTML=html;

});

}

function sendComment(name,message){

fetch("save_comment.php",{
method:"POST",
headers:{
"Content-Type":"application/x-www-form-urlencoded"
},
body:"name="+encodeURIComponent(name)+"&message="+encodeURIComponent(message)
})
.then(res=>res.text())
.then(()=>{

alert("Ucapan berhasil dikirim");
loadComments();

});

}


// ================== ESCAPE HTML ==================
function escapeHtml(str){

if(!str) return "";

return str.replace(/[&<>]/g,function(m){

if(m==="&") return "&amp;";
if(m==="<") return "&lt;";
if(m===">") return "&gt;";

});

}


// ================== DROPDOWN TAMU ==================
const guestSelect=document.getElementById("guestSelect");
const openingGuestName=document.getElementById("openingGuestName");
const insideGuestName=document.getElementById("insideGuestName");

function populateDropdown(){

if(!guestSelect) return;

guestSelect.innerHTML='<option value="Bpk/Keluarga">-- Pilih Nama Tamu --</option>';

allGuestNames.forEach(name=>{

const option=document.createElement("option");

option.value=name;
option.textContent=name;

guestSelect.appendChild(option);

});

}

function updateGuestName(name){

if(openingGuestName) openingGuestName.innerHTML=name;
if(insideGuestName) insideGuestName.innerHTML=name;

localStorage.setItem("weddingGuestName",name);

}

if(guestSelect){

guestSelect.addEventListener("change",function(){

const name=this.value;

if(name!=="Bpk/Keluarga"){
updateGuestName(name);
}

});

}


// ================== RSVP ==================
const rsvpForm=document.getElementById("rsvpForm");
const rsvpStatus=document.getElementById("rsvpStatus");
const jumlahGroup=document.getElementById("jumlahGroup");

if(rsvpStatus){

rsvpStatus.addEventListener("change",function(){

if(this.value==="Hadir"){
jumlahGroup.style.display="block";
}else{
jumlahGroup.style.display="none";
}

});

}

if(rsvpForm){

rsvpForm.addEventListener("submit",function(e){

e.preventDefault();

const name=document.getElementById("rsvpName").value.trim();
const status=document.getElementById("rsvpStatus").value;
const jumlah=document.getElementById("rsvpJumlah").value;

if(!name || !status){
alert("Isi data dengan benar");
return;
}

addConfirmation(name,status,jumlah);

alert("Terima kasih konfirmasinya");

rsvpForm.reset();
jumlahGroup.style.display="none";

});

}


// ================== FORM KOMENTAR ==================
const commentForm=document.getElementById("comment-form");

if(commentForm){

commentForm.addEventListener("submit",function(e){

e.preventDefault();

const name=document.getElementById("comment-name").value.trim();
const message=document.getElementById("comment-message").value.trim();

if(!name || !message){
alert("Isi nama dan ucapan");
return;
}

sendComment(name,message);
commentForm.reset();

});

}


// ================== COUNTDOWN ==================
function updateCountdown(){

const weddingDate=new Date(2026,3,12,9,0,0);
const now=new Date();

const diff=weddingDate-now;

if(diff<=0) return;

const days=Math.floor(diff/(1000*60*60*24));
const hours=Math.floor((diff%(1000*60*60*24))/(1000*60*60));
const minutes=Math.floor((diff%(1000*60*60))/(1000*60));
const seconds=Math.floor((diff%(1000*60))/1000);

document.getElementById("days").innerHTML=days;
document.getElementById("hours").innerHTML=hours;
document.getElementById("minutes").innerHTML=minutes;
document.getElementById("seconds").innerHTML=seconds;

}

setInterval(updateCountdown,1000);
updateCountdown();


// ================== MUSIC ==================
const musicToggle=document.getElementById("music-toggle");
const audio=document.getElementById("background-music");
let musicPlaying=true;

if(audio){

audio.volume=0.3;

musicToggle.addEventListener("click",function(){

if(musicPlaying){
audio.pause();
musicToggle.innerHTML="Musik : OFF";
}else{
audio.play();
musicToggle.innerHTML="Musik : ON";
}

musicPlaying=!musicPlaying;

});

}


// ================== BUKA UNDANGAN ==================
const openBtn=document.getElementById("open-invitation");
const openingScreen=document.getElementById("opening-screen");
const mainInvitation=document.getElementById("main-invitation");

if(openBtn){

openBtn.addEventListener("click",function(){

openingScreen.classList.remove("active");
mainInvitation.classList.add("active");

if(audio){
audio.play();
}

});

}


// ================== PAUSE MUSIC PINDAH TAB ==================
document.addEventListener("visibilitychange",function(){

if(!audio) return;

if(document.hidden){
audio.pause();
}else if(musicPlaying){
audio.play();
}

});


// ================== INISIALISASI ==================
populateDropdown();
renderConfirmedList();
loadComments();

});